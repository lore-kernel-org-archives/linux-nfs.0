From: =?ISO-8859-15?Q?Sven_K=F6hler?= <skoehler@upb.de>
Subject: why do i get "Stale NFS file handle" for hours?
Date: Sun, 05 Sep 2004 03:06:10 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <chdp06$e56$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S265489AbUIEBLU@vger.kernel.org>
To: linux-kernel@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi,

i think i know what's going an, and why i get the "stale nfs handle" 
error-message when the NFS server is restartet (real reboot, or a simply 
/etc/init.d/nfs restart) but what i don't understand is, why the NFS 
client doesn't "remount" the filesystem autmatically. In case of NFS 
over tcp, the NFS client could easily detect a restart of the NFS server 
(the tcp-connection was aborted) or are there other factors that keep 
the NFS client from recognizing such stuff?

The scenaria that made me writing this, is that i'm setting up an NFS 
server at my college right now. It will export a directory to many 
clients where i don't have root-access. The NFS-directories are mounted 
by the clients via automounter, and if i restart my Server for any 
reason, i will get the "stale nfs handle" for hours. The kernel does 
neither remount nor unmount the directory, and the automounter simply 
doesn't unmount it too. It keeps mounted, and that will cause me 
troubles for hours.

Were that any thought on that subject here or in any other mailinglist?
Is there any chance, that this might be improved in the future somehow?


Thx
   Sven
