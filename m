Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:58852 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754550AbZEIUlf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 9 May 2009 16:41:35 -0400
Subject: Re: NFS issues with recent kernels [long]
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: =?ISO-8859-1?Q?Andr=E9?= Berger <andre.berger@web.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Guennadi Liakhovetski <g.liakhovetski@gmx.de>
In-Reply-To: <20090509185736.GF3801@fuchs>
References: <20090417102659.GC55096@fuchs>
	 <B05C16C7-53B5-4E26-8239-956C600CF452@oracle.com>
	 <20090420091454.GB614@fuchs>
	 <F1250240-F050-47B7-9569-54941AAAD572@oracle.com>
	 <20090421043642.GA52257@fuchs> <20090508193813.GC3801@fuchs>
	 <8D7394C9-0142-4635-88E5-139F4F5F39F6@oracle.com>
	 <20090508203751.GD3801@fuchs>
	 <1241815735.7291.1.camel@heimdal.trondhjem.org>
	 <20090509185736.GF3801@fuchs>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 09 May 2009 16:41:31 -0400
Message-Id: <1241901691.5101.26.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2009-05-09 at 20:57 +0200, André Berger wrote:
> * Trond Myklebust (2009-05-08):
> > On Fri, 2009-05-08 at 22:37 +0200, André Berger wrote:
> > > * Chuck Lever (2009-05-08):
> > > > On May 8, 2009, at 3:38 PM, André Berger wrote:
> > > >> * André Berger (2009-04-21):
> > > >>> * Chuck Lever (2009-04-20):
> > > >>>> On Apr 20, 2009, at 5:14 AM, André Berger wrote:
> > > >>>>> * Chuck Lever (2009-04-17):
> > > [...]
> > > > Assuming 192.168.1.8 is your server, frame 79 and 622 report FSINFO  
> > > > results:
> > > >
> > > > Network File System, FSINFO Reply
> > > >     [Program Version: 3]
> > > >     [V3 Procedure: FSINFO (19)]
> > > >     Status: NFS3_OK (0)
> > > >     obj_attributes
> > > >         attributes_follow: no value (0)
> > > >     rtmax: 16384
> > > >     rtpref: 16384
> > > >     rtmult: 4096
> > > >     wtmax: 16384
> > > >     wtpref: 16384
> > > >     wtmult: 4096
> > > >     dtpref: 4096
> > > >     maxfilesize: 2194719883264
> > > >     time delta: 1.000000000 seconds
> > > >         seconds: 1
> > > >         nano seconds: 0
> > > >     Properties: 0x0000001b
> > > >         1... . = SETATTR can set time on server
> > > >         .1.. . = PATHCONF is valid for all files
> > > >         ...1 . = File System supports symbolic links
> > > >         .... 1 = File System supports hard links
> > > >
> > > > says your server operating system supports NFS rsize and wsize maxima of 
> > > > 16384 bytes.
> > > >
> > > > RFC 1813:
> > > >> rtmax
> > > >> The maximum size in bytes of a READ request supported by the server.  
> > > >> Any READ with a number greater than rtmax will result in a short read of 
> > > >> rtmax bytes or less.
> > > 
> > > My OS is 2.6.29.2, Debian etch, on a PPC system. I swear I got 32K
> > > [rw]size with kernels < 2.6.19, at least "mount" reported them as
> > > such. With recent kernels, "mount" and your analysis agree on just
> > > 16K. So, what can I do?
> > 
> > There is nothing the client can do as long as the server says it won't
> > accept NFS requests with read or write sizes > 16k. You therefore need
> > to fix the server.
> 
> So what can I do to fix this? I've upgraded to nfs-utils-1.1.4 in the
> meantime, 1.1.5 and both 1.1.6 give me 
> 
>   make[2]: Entering directory `/tmp/nfs-utils-1.1.5/support/misc'
>   gcc -DHAVE_CONFIG_H -I. -I../../support/include   -I/usr/include  -D_GNU_SOURCE -Wall -Wstrict-prototypes  -pipe -g -O2 -MT tcpwrapper.o -MD -MP -MF .deps/tcpwrapper.Tpo -c -o tcpwrapper.o tcpwrapper.c
>   tcpwrapper.c: In function ‘haccess_add’:
>   tcpwrapper.c:117: warning: implicit declaration of function ‘TAILQ_EMPTY’
>   tcpwrapper.c:119: error: expected expression before ‘else’
>   tcpwrapper.c: In function ‘haccess_lookup’:
>   tcpwrapper.c:131: warning: implicit declaration of function ‘TAILQ_FOREACH’
>   tcpwrapper.c:131: error: ‘list’ undeclared (first use in this function)
>   tcpwrapper.c:131: error: (Each undeclared identifier is reported only once
>   tcpwrapper.c:131: error: for each function it appears in.)
>   tcpwrapper.c:131: error: expected ‘;’ before ‘{’ token
>   make[2]: *** [tcpwrapper.o] Error 1
>   make[2]: Leaving directory `/tmp/nfs-utils-1.1.5/support/misc'
>   make[1]: *** [all-recursive] Error 1
>   make[1]: Leaving directory `/tmp/nfs-utils-1.1.5/support'
>   make: *** [all-recursive] Error 1
> 
> with 
> 
>   ./configure --prefix=/usr/local --sysconfdir=/etc --with-tcp-wrappers=/usr/include --with-statedir=/var/lib/nfs
> 
> I've already upgraded tcpd to the Lenny version 7.6.q-16 (from
> source), but that didn't help. 
> 
> With 1.1.4, I still get 16384 [rw]size while 32768 were requested. 


If the server is based on a recent Linux kernel, then you should check
the value of /proc/fs/nfsd/max_block_size. If it is less than 32k, then
try increasing it.

Cheers
  Trond

