Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:54931 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753750Ab2KSRG0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Nov 2012 12:06:26 -0500
Received: by mail-wg0-f44.google.com with SMTP id dr13so2972014wgb.1
        for <linux-nfs@vger.kernel.org>; Mon, 19 Nov 2012 09:06:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAGXUOG+Px7tBTYH_9e93dOdxUweoE64aLLmRFa4BmyejC9Riug@mail.gmail.com>
References: <CAGXUOGKWDB11zoqZ9zofBgJhJ3Jw0mhZh9QUF8up-1LGCVQ2zw@mail.gmail.com>
 <CAGXUOG+Px7tBTYH_9e93dOdxUweoE64aLLmRFa4BmyejC9Riug@mail.gmail.com>
From: =?UTF-8?Q?Milovan_Krivokapi=C4=87?= <milovan.krivokapic@gmail.com>
Date: Mon, 19 Nov 2012 18:06:05 +0100
Message-ID: <CAGXUOGLFKKFOjPXHVhr6j7T_4VNKeai4Bmosu44Lsdbs=XJOdQ@mail.gmail.com>
Subject: Fwd: [Question] NFS and default file / folder permission
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, a quick question:
I have a problem regarding file permissions on NFS. Umask works for
new files well, but if I get a file via Skype with permission like 600
and then I put that file on NFS, it keeps permission 600 thus others
from a group cant use it at all (I am sharing files via common group).

So the question is how to enforce some default file / folder
permission on NFS? So in this example, I put file on NFS as client
with 600 and it turns into 660 or similar (kind like a mask).

Is it even possible or you have any suggestions?
Debian 6 is a NFS server, clients are Kubuntu 12.04.1 stations that
mounted NFS exported folder.

Thank you very much in advance.
