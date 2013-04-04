Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:38169 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762715Ab3DDPb6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Apr 2013 11:31:58 -0400
References: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com> <20130404151507.GA8484@umich.edu>
In-Reply-To: <20130404151507.GA8484@umich.edu>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <05CFAB4A-8329-4657-B250-1A36105086AA@oracle.com>
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        linux-nfs <linux-nfs@vger.kernel.org>
From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: readdir vs. getattr
Date: Thu, 4 Apr 2013 08:32:42 -0700
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Apr 4, 2013, at 8:15 AM, Jim Rees <rees@umich.edu> wrote:

> Tigran Mkrtchyan wrote:
> 
>  we have a directory with 50K (number of )  files in it.
>  The user does a 'ls' and I can see READDIR4. To
>  get the complete listing a client need to send ~380 requests.
>  Now user does yet another 'ls' in the same directory.
>  The client sends a GETATTR  on directorie's FH
>  (actually two of GETATTRS - why?!!) and discovers that a
>  directory didn't change and re-uses existing listing, BUT!!!
>  for each file in the directory it sends a GETATTR to discover
>  is  the file's attributes are changed. For 50K files it's a 50K requests.
> 
> So is this a "ls -l"? Because for "ls" it shouldn't stat all the files.

Default these days is ls --color


> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
