Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f46.google.com ([209.85.215.46]:48671 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932602AbaCSLZp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Mar 2014 07:25:45 -0400
Received: by mail-la0-f46.google.com with SMTP id hr17so5735179lab.5
        for <linux-nfs@vger.kernel.org>; Wed, 19 Mar 2014 04:25:44 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 19 Mar 2014 07:25:43 -0400
Message-ID: <CAHEKYV7JKuYaQv7c+CEtUZN+AXgR0XamphEtD+on1kw7FSiakg@mail.gmail.com>
Subject: Exporting partition mounted inside another
From: Mauricio Tavares <raubvogel@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

    I have in my NFSv4 server a directory called /exports where I
place everything I want to export:

/dev/vg1/logs            19.7G    651.0M     19.0G   3% /export/logs
/dev/vg1/home           196.9G    163.8G     32.9G  83% /export/home
/dev/vg1/pickles        504.0G     62.7G    441.2G  12% /export/home/pickles
/dev/vg1/stuff           98.4G     21.9G     76.5G  22% /export/public

Note that user pickles does have a lot of crap, so he gets to have his
own partition. My own home dir is in /export/home/raub. Now, I export
them as:

spindizzy> cat /etc/exports
/export 10.0.0.0/24(ro,fsid=0,no_subtree_check,sync)
/export/logs 10.0.0.21/24(rw,insecure,root_squash,no_subtree_check,sync)
/export/home 10.0.0.0/24(rw,insecure,root_squash,no_subtree_check,sync)
/export/public 10.0.0.0/24(ro,insecure,root_squash,no_subtree_check,sync)
spindizzy>

and mount /export/user using automount,

cat /etc/auto.home
#
# File: /etc/auto.home
#
*   -fstype=nfs4,hard,intr,rsize=8192,wsize=8192 fileserver:/home/&

When I try to automount (say by logging in as saif user) pickles'
homedir, it does not mount /dev/vg1/pickles. Instead, it just mounts
it as if only existed in /dev/vg1/home/pickles in the fileserver:

fileserver:/home/raub     197G  164G   33G  84% /home/raub
fileserver:/home/pickles  197G  164G   33G  84% /home/pickles

Sounds like I misconfigured my /etc/exports, but how?
