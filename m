Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:51215 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762841Ab3DDQPT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Apr 2013 12:15:19 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: readdir vs. getattr
Date: Thu, 4 Apr 2013 16:15:15 +0000
Message-ID: <1365092115.10726.25.camel@leira.trondhjem.org>
References: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com>
	 <20130404151507.GA8484@umich.edu>
	 <05CFAB4A-8329-4657-B250-1A36105086AA@oracle.com>
	 <20130404160142.GA8739@umich.edu>
In-Reply-To: <20130404160142.GA8739@umich.edu>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-04-04 at 12:01 -0400, Jim Rees wrote:
> Chuck Lever wrote:
> 
>   > So is this a "ls -l"? Because for "ls" it shouldn't stat all the files.
>   
>   Default these days is ls --color
> 
> No it's not, at least not on linux. From the man page:
> 
> "Using color to distinguish file types is disabled both by default and with
> --color=never."

Yes, but a number of Linux distros override that in /etc/profile. For
instance all Red Hat/Fedora distros have aliases for ls that map them to
'ls --color=auto'

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
