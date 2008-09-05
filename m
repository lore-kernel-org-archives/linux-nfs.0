From: Aaron Straus <aaron@merfinllc.com>
Subject: Re: [NFS] blocks of zeros (NULLs) in NFS files in kernels >= 2.6.20
Date: Fri, 5 Sep 2008 13:04:55 -0700
Message-ID: <20080905200455.GH22796@merfinllc.com>
References: <20080905191939.GG22796@merfinllc.com> <0A24B45A-9761-4310-B1DB-B4738964E862@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	LKML Kernel <linux-kernel@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754440AbYIEUFK@vger.kernel.org>
In-Reply-To: <0A24B45A-9761-4310-B1DB-B4738964E862@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On Sep 05 03:56 PM, Chuck Lever wrote:
> [ replacing cc: nfs@sf.net with linux-nfs@vger.kernel.org, and neil's  
> old address with his current one ]

Sorry I probably grabbed an old MAINTAINERS file.

> On Sep 5, 2008, at Sep 5, 2008, 3:19 PM, Aaron Straus wrote:
> > Writer_Version     Outcome:
> > <= 2.6.19          OK
> > >= 2.6.20	    BAD
> 
> Up to which kernel?  Recent ones may address this issue already.

BAD up to 2.6.27-rc? 

I have to see exactly which is the last rc version I tested.

> > I can try to bisect between 2.6.19 <-> 2.6.20.
> 
> That's a good start.

OK will try to bisect.

> Comparing a wire trace with strace output, starting with the writing  
> client, might also be illuminating.  We prefer wireshark as it uses  
> good default trace settings, parses the wire bytes and displays them  
> coherently, and allows you to sort the frames in various useful ways.

OK.  Could you also try to reproduce on your side using those python
programs?  I want to make sure it's not something specific with our
mounts, etc.

Thanks!
					=a=


-- 
===================
Aaron Straus
aaron@merfinllc.com
