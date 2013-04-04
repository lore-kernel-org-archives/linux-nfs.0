Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:55579 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762698Ab3DDQBu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Apr 2013 12:01:50 -0400
Date: Thu, 4 Apr 2013 12:01:42 -0400
From: Jim Rees <rees@umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: readdir vs. getattr
Message-ID: <20130404160142.GA8739@umich.edu>
References: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com>
 <20130404151507.GA8484@umich.edu>
 <05CFAB4A-8329-4657-B250-1A36105086AA@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <05CFAB4A-8329-4657-B250-1A36105086AA@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:

  > So is this a "ls -l"? Because for "ls" it shouldn't stat all the files.
  
  Default these days is ls --color

No it's not, at least not on linux. From the man page:

"Using color to distinguish file types is disabled both by default and with
--color=never."
