Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f41.google.com ([209.85.212.41]:41127 "EHLO
	mail-vb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762198Ab3DDOrP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Apr 2013 10:47:15 -0400
Received: by mail-vb0-f41.google.com with SMTP id f13so1385528vbg.0
        for <linux-nfs@vger.kernel.org>; Thu, 04 Apr 2013 07:47:14 -0700 (PDT)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
Date: Thu, 4 Apr 2013 16:47:14 +0200
Message-ID: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com>
Subject: readdir vs. getattr
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

here is the story:

we have a directory with 50K (number of )  files in it.
The user does a 'ls' and I can see READDIR4. To
get the complete listing a client need to send ~380 requests.
Now user does yet another 'ls' in the same directory.
The client sends a GETATTR  on directorie's FH
(actually two of GETATTRS - why?!!) and discovers that a
directory didn't change and re-uses existing listing, BUT!!!
for each file in the directory it sends a GETATTR to discover
is  the file's attributes are changed. For 50K files it's a 50K requests.

I believe there is a way to make client smart and in some
situations prefer READDIR over GETATTR.

Tigran.
