From: Peter Staubach <staubach@redhat.com>
Subject: Re: [NFS] Stale NFS file handle error
Date: Fri, 11 Jul 2008 09:38:40 -0400
Message-ID: <48776260.5010503@redhat.com>
References: <48774466.508@limepepper.co.uk> <48775714.6090107@redhat.com>
	<48775EBC.4090008@limepepper.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Tom H <tom-6kxvdouIZplzjhtm8Ag3mw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:35165 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752450AbYGKNiw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jul 2008 09:38:52 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KHIpm-0006cY-Db
	for linux-nfs@vger.kernel.org; Fri, 11 Jul 2008 23:38:50 +1000
In-Reply-To: <48775EBC.4090008-6kxvdouIZplzjhtm8Ag3mw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom H wrote:
> Peter Staubach wrote:
>   
>> Are you sure that you don't have two (or more) different NFS
>> clients working in the same directory?
>>
>> The ESTALE error usually occurs when a change is made on the
>> server to something that a client is accessing, perhaps
>> directly on the server or more commonly, by a different NFS
>> client.
>>     
>
> I'm as sure as I can be that the app is not opening the file multiple 
> times, the previous lines of code actually generate the folder and its 
> all sequential. The file names are all deterministic, only 1 process 
> running and nothing else accesses those files on the server. I have 
> checked for things like backup processes.
>
> It happens so infrequently that I get the feeling that its more likely 
> something else.
>
> I guess that I am looking for ways to troubleshoot the problem, maybe 
> with debug tools or whatever the guru nfs people would use...

It sounds like you are only using 1 NFS client?  Do you have
the same file system from the server mounted in more than one
place on this client?

You could try using something like tshark or tcpdump to capture
the network traffic when the error occurs, but I suspect that
if it really only happens infrequently, then you would end up
with gigabytes of capture and may or may not actually be able to
identify the traffic when the problem occurs.

Alternately, when the problem occurs, see if the file being
accessed really does continue to exist and is the same file,
ie. wasn't removed and then a new file with the same name
created in its place.

       ps

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

