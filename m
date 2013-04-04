Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:60793 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762332Ab3DDPPM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Apr 2013 11:15:12 -0400
Date: Thu, 4 Apr 2013 11:15:07 -0400
From: Jim Rees <rees@umich.edu>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: readdir vs. getattr
Message-ID: <20130404151507.GA8484@umich.edu>
References: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tigran Mkrtchyan wrote:

  we have a directory with 50K (number of )  files in it.
  The user does a 'ls' and I can see READDIR4. To
  get the complete listing a client need to send ~380 requests.
  Now user does yet another 'ls' in the same directory.
  The client sends a GETATTR  on directorie's FH
  (actually two of GETATTRS - why?!!) and discovers that a
  directory didn't change and re-uses existing listing, BUT!!!
  for each file in the directory it sends a GETATTR to discover
  is  the file's attributes are changed. For 50K files it's a 50K requests.

So is this a "ls -l"? Because for "ls" it shouldn't stat all the files.
