From: Juan Gomez <juang@us.ibm.com>
Subject: Why NFS server does not pass lock requests via VFS lock() op?
Date: Wed, 9 Oct 2002 16:11:19 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <OF3AABFEC7.87E5D2A4-ON87256C4D.007E3028@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: nfs@lists.sourceforge.net
List-ID: <nfs.lists.sourceforge.net>





Could anyone remind me of why NFS kernel would not pass byte range lock
requests to the underlying filsystem at the server side?
I think another person at IBM (Brian?) submitted a patch for this but such
patch never got included in the distribution.

I think a patch to pass lock requests to the underlying filesystem does not
affect single node NFS servers and it enables us to
support clustered Linux-based NAS heads over distributed file systems.

Juan
