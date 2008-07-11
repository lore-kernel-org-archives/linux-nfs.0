From: Tom H <tom-6kxvdouIZplzjhtm8Ag3mw@public.gmane.org>
Subject: Re: [NFS] Stale NFS file handle error
Date: Fri, 11 Jul 2008 14:23:08 +0100
Message-ID: <48775EBC.4090008@limepepper.co.uk>
References: <48774466.508@limepepper.co.uk> <48775714.6090107@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:57521 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752552AbYGKNXc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jul 2008 09:23:32 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KHIav-0005WL-TP
	for linux-nfs@vger.kernel.org; Fri, 11 Jul 2008 23:23:29 +1000
In-Reply-To: <48775714.6090107@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Peter Staubach wrote:
> Are you sure that you don't have two (or more) different NFS
> clients working in the same directory?
> 
> The ESTALE error usually occurs when a change is made on the
> server to something that a client is accessing, perhaps
> directly on the server or more commonly, by a different NFS
> client.

I'm as sure as I can be that the app is not opening the file multiple 
times, the previous lines of code actually generate the folder and its 
all sequential. The file names are all deterministic, only 1 process 
running and nothing else accesses those files on the server. I have 
checked for things like backup processes.

It happens so infrequently that I get the feeling that its more likely 
something else.

I guess that I am looking for ways to troubleshoot the problem, maybe 
with debug tools or whatever the guru nfs people would use...

Tom

-------------------------------------------------------------------------
Sponsored by: SourceForge.net Community Choice Awards: VOTE NOW!
Studies have shown that voting for your favorite open source project,
along with a healthy diet, reduces your potential for chronic lameness
and boredom. Vote Now at http://www.sourceforge.net/community/cca08
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

