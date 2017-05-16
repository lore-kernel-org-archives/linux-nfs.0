Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3.molgen.mpg.de ([141.14.17.11]:54588 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750932AbdEPLGO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 May 2017 07:06:14 -0400
To: linux-nfs@vger.kernel.org
Cc: it+linux-nfs@molgen.mpg.de
From: Paul Menzel <pmenzel@molgen.mpg.de>
Subject: How to debug permission denied issues?
Message-ID: <bbe53cbb-4d90-1d89-089d-c157b45ea426@molgen.mpg.de>
Date: Tue, 16 May 2017 13:06:12 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear NFS folks,


With Linux 4.9.x there are issues, that the NFSD servers denies access 
to NFS mounts. Other clients can still connect fine. A restart of the 
*client* fixes the issue.

We believe that this is related to a restart of a NIS server, and that 
NFSD is now unable to authenticate the requests. Maybe some cache 
mismatch of some client identifications?

```
root:sigchld:~/# mount -v -t nfs hopp:/home/joey /mnt
mount.nfs: timeout set for Tue May 16 12:57:04 2017
mount.nfs: trying text-based options 
'vers=4,addr=141.14.25.186,clientaddr=141.14.16.120'
mount.nfs: mount(2): Permission denied
mount.nfs: access denied by server while mounting hopp:/home/joey
```

Could you please point me to the right direction, how this issue can be 
debugged?

A first step would be to get debug messages from NFSD, why exactly the 
permission was denied to mount the directory.


Kind regards,

Paul
