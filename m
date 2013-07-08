Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:65456 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000Ab3GHMrC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jul 2013 08:47:02 -0400
Received: by mail-wi0-f178.google.com with SMTP id k10so3902258wiv.11
        for <linux-nfs@vger.kernel.org>; Mon, 08 Jul 2013 05:47:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAF38w7Xx0_TqZem6cen+EJKpUrziGT_dAVcjG7oFFwM+ANm5mA@mail.gmail.com>
References: <CAF38w7Xx0_TqZem6cen+EJKpUrziGT_dAVcjG7oFFwM+ANm5mA@mail.gmail.com>
Date: Mon, 8 Jul 2013 14:47:00 +0200
Message-ID: <CAF38w7Xf87k=GfM38XcO+ag+Na=f=Mg1KDn0jv2Y8Yp6Q_5a=g@mail.gmail.com>
Subject: Fwd: Problem with sharing mounted iso
From: Johan GUILBAUD <guilbaud.johan@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello !

I have a problem to access a mounted ISO through NFS protocol

i have a server (RHEL6) on which are mounted ISOs
i have a lot of client accessing files into ISO via the NFS share

My problem is clients (RHEL5 & 6, Solaris 8 & 10) don't see content of
ISO folder

In example :

on NFS server i have a folder /pub/ where the ISO are mounted (ie :
with the iso mybeautifuliso.iso on the mount point
"/pub/mybeautifuliso/") there are also, for test, text files in /pub/
NFS shares content of /pub


Client see tests text files, and folder "mybeautifuliso" but this one
is empty...


thanks for help

--
GUILBAUD Johan
