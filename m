Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:64403 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435AbaF3CHe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Jun 2014 22:07:34 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so6609706qcz.0
        for <linux-nfs@vger.kernel.org>; Sun, 29 Jun 2014 19:07:33 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 30 Jun 2014 12:07:33 +1000
Message-ID: <CA++rrJoQG76ag2gTBo6nA3s1nM1gVNoGR4+8YuzA6yjJqMufBQ@mail.gmail.com>
Subject: NFS working but I have unwanted 500MB quota
From: Richard Thornton <richie.thornton@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Can somebody help please.

I setup NFS between two Ubuntu 14.04 systems and I can save files to
the server but I have a 500MB quota I never setup (The btrfs partition
has 1TB remaining but I can see I have only 500MB remaining on the
directory, trying to copy anything larger gives an error), I would
like to permanently remove the quota but can't seem to find the right
info and commands.

I used this page as a reference
https://help.ubuntu.com/community/SettingUpNFSHowTo.

While trying to figure the quota issue out, I installed "quota" but
haven't had any luck with the quota, repquota, edquota, quotacheck,
setquota commands...very confusing.

Googling has given me nothing.

Thanks for taking a look.

Cheers
Richard
