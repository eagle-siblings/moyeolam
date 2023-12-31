package com.ssafy.moyeolam.global.advice;

import com.ssafy.moyeolam.domain.alarmgroup.exception.AlarmGroupException;
import com.ssafy.moyeolam.domain.auth.exception.AuthException;
import com.ssafy.moyeolam.domain.friend.exception.FriendException;
import com.ssafy.moyeolam.domain.member.exception.MemberException;
import com.ssafy.moyeolam.domain.notification.exception.NotificationException;
import com.ssafy.moyeolam.global.common.response.EnvelopeResponse;
import com.ssafy.moyeolam.global.common.exception.GlobalErrorInfo;
import com.ssafy.moyeolam.global.common.exception.GlobalException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice
public class ExceptionControllerAdvice {

    @ExceptionHandler(RuntimeException.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public EnvelopeResponse RuntimeExceptionHandler(RuntimeException e) {
        e.printStackTrace();
        return EnvelopeResponse.builder()
                .code(GlobalErrorInfo.INTERNAL_SERVER_ERROR.getCode())
                .message(GlobalErrorInfo.INTERNAL_SERVER_ERROR.getMessage())
                .build();
    }

    @ExceptionHandler(GlobalException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public EnvelopeResponse GlobalExceptionHandler(GlobalException e) {
        e.printStackTrace();
        return EnvelopeResponse.builder()
                .code(e.getInfo().getCode())
                .message(e.getInfo().getMessage())
                .build();
    }

    @ExceptionHandler(AlarmGroupException.class)
    @ResponseStatus(HttpStatus.OK)
    public EnvelopeResponse AlarmGroupExceptionHandler(AlarmGroupException e) {
        e.printStackTrace();
        return EnvelopeResponse.builder()
                .code(e.getInfo().getCode())
                .message(e.getInfo().getMessage())
                .build();
    }

    @ExceptionHandler(FriendException.class)
    @ResponseStatus(HttpStatus.OK)
    public EnvelopeResponse FriendExceptionHandler(FriendException e) {
        e.printStackTrace();
        return EnvelopeResponse.builder()
                .code(e.getInfo().getCode())
                .message(e.getInfo().getMessage())
                .build();
    }

    @ExceptionHandler(MemberException.class)
    @ResponseStatus(HttpStatus.OK)
    public EnvelopeResponse MemberExceptionHandler(MemberException e) {
        e.printStackTrace();
        return EnvelopeResponse.builder()
                .code(e.getInfo().getCode())
                .message(e.getInfo().getMessage())
                .build();
    }

    @ExceptionHandler(NotificationException.class)
    @ResponseStatus(HttpStatus.OK)
    public EnvelopeResponse NotificationExceptionHandler(NotificationException e) {
        e.printStackTrace();
        return EnvelopeResponse.builder()
                .code(e.getInfo().getCode())
                .message(e.getInfo().getMessage())
                .build();
    }

    @ExceptionHandler(AuthException.class)
    @ResponseStatus(HttpStatus.OK)
    public EnvelopeResponse AuthExceptionHandler(AuthException e) {
        e.printStackTrace();
        return EnvelopeResponse.builder()
                .code(e.getInfo().getCode())
                .message(e.getInfo().getMessage())
                .build();
    }
}
