Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f172.google.com ([209.85.214.172]:36198 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752022Ab3F0GcF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jun 2013 02:32:05 -0400
Received: by mail-ob0-f172.google.com with SMTP id wo10so346075obc.3
        for <linux-nfs@vger.kernel.org>; Wed, 26 Jun 2013 23:32:04 -0700 (PDT)
Message-ID: <51CBDC5F.8090109@gmail.com>
Date: Thu, 27 Jun 2013 00:31:59 -0600
From: John Haiducek <jhaiduce@gmail.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Can't mount NFSv4 with kerberos on Debian Wheezy
References: <51BF21E0.8060805@gmail.com> <51BF23FE.4070106@gmail.com> <3E91EC3C-EA92-41A6-9EDA-42E108E83024@oracle.com> <51BFBA5A.5050104@gmail.com> <8565C805-9C6C-4C06-83C0-8574EA90DA53@oracle.com> <51C0AB95.9060509@gmail.com> <EB30924A-D9F1-49C5-A727-DF8B4B2AFDAC@oracle.com> <CAFYD6QXKcNkAgmJV5KyMOpx-cXg35GnYzBg9mg+LFdW83NyQZQ@mail.gmail.com> <A2112E2B-FA65-4FF2-BC21-B78BBDC75CB1@oracle.com>
In-Reply-To: <A2112E2B-FA65-4FF2-BC21-B78BBDC75CB1@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck,

I upgraded my system to Debian experimental yesterday and that fixed my 
NFS problem. Downgraded again to Wheezy and NFS still works. (I had put 
NFS on the back burner; the upgrade and downgrade was part of an attempt 
to install Skype, which eventually proved successful.) So apparently the 
problem was a broken installation of one of the NFS packages or a 
dependency. Presumably I could have fixed it by re-installing the one or 
two offending packages, but the "reinstall almost everything on the 
system" approach seems to have worked too. Thank you again for all your 
help!

John

