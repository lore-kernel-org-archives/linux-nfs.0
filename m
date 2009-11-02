From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: IPv6 support
Date: Mon, 02 Nov 2009 13:50:21 +0530
Message-ID: <4AEE9645.6010503@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck et al,

Thanks for all the excellent work on IPv6 support. There have been
considerable amount of development that has been happening recently.
However, it's not very clear what are the missing pieces or open
problems (if any).

>From what I understand, the current status is (CMIW):

+ kernel support
  - client side and server (kernel pieces) are almost there and the
    missing pieces are expected to get in by 2.6.32.
+ userspace support
  - nfsd support has already been added but disabled temporarily till
    we get statd and mountd IPv6 aware.
  - making statd IPv6 aware is currently under development/review.
  - mount.nfs changes - done?
  - rpc.mountd, exportfs changes - TBD.

Is the above information correct? How far we are from getting full IPv6
support?


Thanks,

-- 
Suresh Jayaraman
