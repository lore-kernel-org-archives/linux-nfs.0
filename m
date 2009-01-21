From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Wed, 21 Jan 2009 14:29:00 -0500
Message-ID: <1232566140.7692.64.camel@heimdal.trondhjem.org>
References: <4970B451.4080201@RedHat.com> 	 <5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com> 	 <497757D1.7090908@RedHat.com> 	 <F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steve Dickson <SteveD@redhat.com>, Linux NFSv4 mailing list <nfsv4@linux-nfs.org>, Linux NFS Mailing list <linux-nfs@vger.kernel.org>,  SystemTAP <systemtap@sources.redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <systemtap-return-10966-gls-systemtap=m.gmane.org@sourceware.org>
In-Reply-To: <F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>
List-Unsubscribe: <mailto:systemtap-unsubscribe-gls-systemtap=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:systemtap-subscribe@sourceware.org>
List-Post: <mailto:systemtap@sourceware.org>
List-Help: <mailto:systemtap-help@sourceware.org>, <http://sourceware.org/lists.html#faqs>
Sender: systemtap-owner@sourceware.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-01-21 at 13:01 -0500, Chuck Lever wrote:
> `rpcdebug -m nfs -s mount` also enables the dprintks in fs/nfs/ 
> mount_clnt.c, at least.  As with most dprintk infrastructure in NFS,  
> it's really aimed at developers and not end users or admins.  The  
> rpcbind client is also an integral part of the mount process, so I  
> suggested that too.

This would be my main gripe with suggestions that we convert all the
existing dprintks. As Chuck says, they are pretty much a hodgepodge of
messages designed to help kernel developers to debug the NFS and RPC
code.

If you want something dtrace-like to allow administrators to run scripts
to monitor the health of their cluster and troubleshoot performance
problems, then you really want to start afresh. That really needs to be
designed as a long-term API, and should ideally represent the desired
functionality in a manner that is more or less independent of the
underlying code (something that is clearly not the case for the current
mess of dprintks). Otherwise, scripts will have to be rewritten every
time we make some minor tweak or change to the code (i.e. for every
kernel release).

Cheers
  Trond
