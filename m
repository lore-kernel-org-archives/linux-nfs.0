From: "Garrett Cooper" <yanegomi@gmail.com>
Subject: Generic root=/dev/nfs with nfsroot= boot question
Date: Thu, 30 Oct 2008 11:09:40 -0700
Message-ID: <364299f40810301109s1eb14ae7kc7a4c08f2fb038c5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:30989 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570AbYJ3SJn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Oct 2008 14:09:43 -0400
Received: by nf-out-0910.google.com with SMTP id d3so342034nfc.21
        for <linux-nfs@vger.kernel.org>; Thu, 30 Oct 2008 11:09:40 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi guys,
       I'm not sure if this is the best place to ask this question but
I was wondering whether or not root=/dev/nfs is required when nfsroot=
is specified on a command line, or does specifying nfsroot= imply
root=/dev/nfs?
       I asking because I am part of a group developing on a Linux
platform, and unfortunately this "functionality" was broken between
"releases" for a device because someone went and messed around with
the device tree. This "functionality" works perfectly fine for the
other targets that we support though, and works perfectly fine for
other supported targets.
Thanks,
-Garrett
