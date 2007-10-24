From: David Liontooth <liontooth@cogweb.net>
Subject: Bug#443591: nfs-kernel-server: Unexporting directories no
 longer working
Date: Tue, 23 Oct 2007 17:09:39 -0700
Message-ID: <471E8D43.6080901@cogweb.net>
References: <20070922174231.11200.29119.reportbug@localhost.localdomain>
	<20070923000102.GA29785@uio.no>
	<18167.24613.796605.199161@notabene.brown>
	<46F8483E.3000103@cogweb.net> <20071012195958.GA13362@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, 443591@bugs.debian.org,
	nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IkToh-000809-20
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 17:09:47 -0700
Received: from smtp-9.smtp.ucla.edu ([169.232.48.138])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IkTol-0003xW-CA
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 17:09:52 -0700
In-Reply-To: <20071012195958.GA13362@uio.no>
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

Steinar H. Gunderson wrote:
> On Mon, Sep 24, 2007 at 04:29:02PM -0700, David Liontooth wrote:
>   
>> Hi Neil,
>>
>> Thanks for looking.
>>     
>
> I didn't see an answer to this mail; was the problem forgotten, or was it
> resolved?
>
> /* Steinar */
>   
I didn't hear back from Neil, but the issue should be considered
resolved. I mistakenly believed it was possible to unexport a particular
resource to several hosts, without unexporting other resources.

For instance, I have 

/tv01 \
        134.32.443.30(ro,no_subtree_check,async) \
        134.32.443.32(ro,no_subtree_check,async) \
        134.32.443.33(ro,no_subtree_check,async) \
        134.32.443.34(ro,no_subtree_check,async) \
        134.32.443.35(ro,no_subtree_check,async) \
        134.32.443.36(ro,no_subtree_check,async) \
        134.32.443.37(ro,no_subtree_check,async)

Several other drives have similar entries.

If I understand Neil correctly, it's not possible to unexport /tv01 to
all of these hosts by issuing

	exportfs -u :/tv01

man exportfs says, "To  remove individual export entries, one can
specify a host:/path pair. This deletes the specified entry from xtab
and removes the corresponding kernel entry (if any)."  The man page may
be assuming the resource has only been exported to one host, but it
doesn't state that limitation. Apparently there's no command for
unexporting a resource to all or a subset of hosts; the command works
only if there's a single host.

We could leave the report in place but downgrade it to wishlist. If I've
described the situation correctly, the man page could do with a
revision, for instance using this language:

To remove an export to a host, specify a host:/path pair. This deletes
the specified entry from xtab and removes the corresponding kernel entry
(if any). To remove one or more exports to several hosts, use exportfs -ua.

David

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
