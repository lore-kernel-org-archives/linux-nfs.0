From: Zoot <z00t@gmx.net>
Subject: Re: umount fails with device busy
Date: Thu, 23 Aug 2007 23:15:20 +0200
Message-ID: <20070823211520.GC4822@localhost>
References: <20070823184544.237460@gmx.net> <46CDE805.4090909@oracle.com>
	<46CDEE3A.3040809@redhat.com> <46CDEF90.90007@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOK1X-0007Mj-KE
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 14:15:27 -0700
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1IOK1b-0004gc-A9
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 14:15:32 -0700
In-Reply-To: <46CDEF90.90007@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, Aug 23, 2007 at 04:35:28PM -0400, Chuck Lever wrote:
> >>>When I run umount during these ops I get an device busy. Any help 
> >>>would be very appreciated!
> >>
> >>This is normal and expected behavior.  One problem may be that your 
> >>server is slow, and thus there are RPCs left outstanding for a bit on 
> >>your client after your application exits.  The COMMIT calls from that 
> >>trace suggest that there is dirty data the client is writing back to 
> >>the server. 
> >
> >It seems to me that this should not be the expected behavior unless
> >the file system is mounted "nocto".  Is it?
> 
> I'm a little puzzled myself about what dirty data there might be left 
> after the application quits.  However, I'll be there is an mmap() 
> lurking somewhere in the background...
> 
> Data that was dirtied via a mapped file is not subject to the writeback 
> part of close-to-open.
At least according to the NFS debug output are the commits only related
to .trc files which are used by the app to store it's debug output. Not
used for mmap.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
