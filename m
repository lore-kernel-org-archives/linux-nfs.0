From: Daniel Phillips <phillips@google.com>
Subject: Re: Re: Lock recursion in rpc_pipefs+auth_gss...
Date: Thu, 19 Jan 2006 17:18:48 -0800
Message-ID: <43D03A78.3020707@google.com>
References: <43CFE807.5080304@google.com> <1137712176.11182.20.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EzkvV-0007ng-UJ
	for nfs@lists.sourceforge.net; Thu, 19 Jan 2006 17:18:53 -0800
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EzkvU-0006WG-NX
	for nfs@lists.sourceforge.net; Thu, 19 Jan 2006 17:18:53 -0800
To: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <1137712176.11182.20.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Trond Myklebust wrote:
> On Thu, 2006-01-19 at 11:27 -0800, Daniel Phillips wrote:
>>That in itself should not cause an oops.  I would think there is a
>>reference-counting problem still lurking.  I'm a little concerned that a
>>patch like this one may just make the oops a lot rarer without solving it.
> 
> The lock recursion is _real_: I've been able to trigger it on
> 2.6.16-rc1. The only question here is therefore whether or not it
> suffices to explain the Oops.

I don't see how it could.

I do not doubt the veracity of the lock recursion, but holding the i_sem/mutex
for a long time seems to be one of the things we need to do to trigger the
oops, so this deadlock is our friend.  Does it always trigger the oops?  Do
you have a recipe handy so we can try it here?

The symptoms we see suggest the pipe inode was freed while somebody was
waiting to get the i_mutex.  What prevents this?

Re the lock recursion itself, is there any good reason to serialize upcalls
against downcalls in the first place?

Regards,

Daniel


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
