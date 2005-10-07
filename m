From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [NFS] [PATCH] kNFSD - Allowing rpc.nfsd to setting of the port,
 transport and version the server will use
Date: Fri, 07 Oct 2005 13:26:44 -0400
Message-ID: <4346AFD4.3000009@RedHat.com>
References: <43469FA7.7020908@RedHat.com> <20051007164435.GC9759@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030519AbVJGR1D@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20051007164435.GC9759@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hey Bruce,

J. Bruce Fields wrote:
>
> So the obvious question is what will happen if someone does
> 
> 	rpc.nfsd -N 3
> 
> on a server supporting 2, 3, and 4.
> 
> It looks like the code in svc_create() will set pg_lovers to 2 and
> pg_hivers to 4 in that case.  So if someone tries to use version 3, the
> error they get back will be a somewhat contradictory "sorry, I only
> support versions 2 through 4."
hmmm.... good point... But I wonder if this would be better
handled in rpc.nfsd process; Similar to what happens when
no transports are specified (i.e. both -T and -U flags are set),
the server fails to started.

steved.
