From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [NFS] RE: [autofs] multiple servers per automount
Date: Wed, 15 Oct 2003 07:31:47 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <482A3FA0050D21419C269D13989C6113020AC516@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Joseph V Moss" <jmoss@ichips.intel.com>,
	"Ogden, Aaron A." <aogden@unocal.com>,
	"Mike Waychison" <Michael.Waychison@Sun.COM>,
	"autofs mailing list" <autofs@linux.kernel.org>,
	<nfs@lists.sourceforge.net>,
	"Kernel Mailing List" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "Ian Kent" <raven@themaw.net>
List-ID: <nfs.lists.sourceforge.net>

Ian Kent said:
> Do you think that the possible NFS port allocation problems
> should hold up this work or should it drive updates to NFS?

hi ian-

the port stuff has to be addressed at some point, but i don't
think you should wait for it, because it is behind a long queue
of other RPC work (like Kerberos for Linux NFS) that has a
higher priority.  also, there are other patches that partially
address this limitation, and certainly those will be used by
the desparate few who need it now. :^)

IMHO.
