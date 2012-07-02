Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f174.google.com ([209.85.214.174]:44116 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753429Ab2GBTpi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jul 2012 15:45:38 -0400
Received: by obbuo13 with SMTP id uo13so8642740obb.19
        for <linux-nfs@vger.kernel.org>; Mon, 02 Jul 2012 12:45:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJ2oMhKEXMy9m=nvT6RjNSki_AFAhmbAyK=S87fwFbc2ou-_Wg@mail.gmail.com>
References: <CAJ2oMhKEXMy9m=nvT6RjNSki_AFAhmbAyK=S87fwFbc2ou-_Wg@mail.gmail.com>
Date: Mon, 2 Jul 2012 21:45:37 +0200
Message-ID: <CAJ2oMhJcMg2FknYheJsNu0zDJ-8D-Np6ED7QMWBjL=+MP9ZaOg@mail.gmail.com>
Subject: Modifying IP&mac address
From: Ran Shalit <ranshalit@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I would like to ask your advise concerning modifying ip address:
I need to modify ip address and ethernet address according to some
hardware input in application. This change can be done in u-boot or
linux.
When I consider where is the best place to set the ip/mac address (
u-boot or linux), I also take into account that I will work with NFS
in debug stage.
Now, as far as I understand, If I will modify the ip/mac in linux
instead of u-boot, it can be a problem when working with NFS, becuase
NFS need constant ip address and ethernet address, right ?
Is it a problem to make this changes in linux if working with NFS or
should it be done in u-boot only ?

Thank you,
Ran
