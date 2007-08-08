From: Jeff Layton <jlayton@redhat.com>
Subject: Re: rpc.mountd memory leak
Date: Tue, 7 Aug 2007 20:21:34 -0400
Message-ID: <20070807202134.46460f83.jlayton@redhat.com>
References: <37B62E0F71C9E14B9859FADB1FC3E3E14EB034@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIZIr-0000g6-FA
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 17:21:33 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IIZIv-0008I1-96
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 17:21:37 -0700
In-Reply-To: <37B62E0F71C9E14B9859FADB1FC3E3E14EB034@ala-mail02.corp.ad.wrs.com>
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

On Tue, 7 Aug 2007 14:27:39 -0700
"Kottaridis, Chris" <chris.kottaridis@windriver.com> wrote:

> I've got a customer experiencing a small memory leak in rpc.mountd using
> nfs-utils-1.0.7. For their load it's about 150 KB/day. I have been
> previously pointed me to a memory leak in add_name in
> support/export/client.c. Thanks! they were seeing a 6 MB/ day leak
> before that fix.
>  
> I've had trouble reproducing the same leak here, but in looking through
> the code I believe I have come across another possible memory leak in
> the support/export/client.c file. This time in the client_compose()
> routine. It may be the source of the current 150 KB/day leak my customer
> is seeing.
>  
> I've attached an anlysis from code inspection, but it boils down to the
> fact that the 'he' variable of client_compose() needs to be xfree'd
> before client_compose() returns. The 'he' variable is assigned a
> xmalloc'ed value via either get_hostent() or get_reliable_hostbyaddr().
> Once the client_compose() routine returns the pointer will be lost
> forever. The code is identical in nfs-utils-1.1.0 so I believe the
> memory leak exists there as well.
>  
> I'll keep trying to verify that indeed there is a memory leak here, but
> from code inspection it certainly seems like it.
>  
> Let me know if you agree that client_compose() has a memory leak.
>  

Current nfs-utils git tree seems to do this already. Looks like this
patch fixed it:

commit 1cb4a250fb9f0a8ba34befa47d951430e444a58e
Author: Steinar H. Gunderson <sesse@debian.org>
Date:   Fri May 11 21:02:09 2007 +1000

    Memory leak in mountd
    
    In client_compose(), free() the hostent structure returned before
    exiting. Normally, gethostbyaddr() returns a pointer to a static
    struct, but this hostent comes from either get_reliable_hostbyaddr() or
    get_hostent(), both which return a pointer they privately xmalloc()ed,
    which thus can and should be free()d.
    
    Signed-Off-By: Steinar H. Gunderson <sesse@debian.org>


You might want to test with that code and see if the problem
goes away...

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
