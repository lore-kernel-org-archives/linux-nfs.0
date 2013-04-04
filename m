Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:63894 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763134Ab3DDQfd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Apr 2013 12:35:33 -0400
Date: Thu, 4 Apr 2013 12:35:25 -0400
From: Jim Rees <rees@umich.edu>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: readdir vs. getattr
Message-ID: <20130404163525.GA8953@umich.edu>
References: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com>
 <20130404151507.GA8484@umich.edu>
 <05CFAB4A-8329-4657-B250-1A36105086AA@oracle.com>
 <20130404160142.GA8739@umich.edu>
 <1365092115.10726.25.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1365092115.10726.25.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond wrote:

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

I was actually just trying to figure out whether the application (ls) was
doing all those file stats, or whether readdir was somehow doing them by
mistake. Sounds like it's the application.
