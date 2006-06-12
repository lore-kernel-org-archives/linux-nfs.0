From: "Madhan P" <PMadhan@novell.com>
Subject: Re: [Linux-cluster] [RFC] NLM lock failover admin	interface
Date: Mon, 12 Jun 2006 10:20:57 -0600
Message-ID: <448DE1C1.C935.0084.1@novell.com>
References: <1150089943.26019.18.camel@localhost.localdomain>
	<20060612150053.GC31596@fieldses.org> <448D8BF7.7010105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux clustering <linux-cluster@redhat.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FppAf-00065Y-Bv
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 09:21:45 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FppAf-0000q0-ES
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 09:21:45 -0700
Received: from lucius.provo.novell.com ([137.65.81.172])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FppAf-00057L-5D
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 09:21:45 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>,
	"Wendy Cheng" <wcheng@redhat.com>
In-Reply-To: <448D8BF7.7010105@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

For what it's worth, would second this approach of using a flag to
unexport and associating the cleanup with that.  Another quick hack we
used was to store the NSM entries on a standard location on the
respective exported filesystem, so that notification is sent once the
filesystem comes back online on the destination server and is exported
again.  BTW, this was not on Linux. It was a  simple solution providing
the necessary active/active and active/passive cluster support.

- Madhan

>>> On 6/12/2006 at 9:14:55 pm, in message
<448D8BF7.7010105@redhat.com>, Wendy
Cheng <wcheng@redhat.com> wrote:
> J. Bruce Fields wrote:
> 
>>On Mon, Jun 12, 2006 at 01:25:43AM -0400, Wendy Cheng wrote:
>>  
>>
>>>2. Adding a new flag into "exportfs" command, say "h", such that
>>>
>>>   "exportfs -uh *:/export_path"
>>>
>>>would un-export the entry and drop the NLM locks associated with
the
>>>entry.
>>>    
>>>
>>
>>What does the kernel interface end up looking like in that case?
>>
>>  
>>
> Happy to see this new exportfs command gets positive response - it
was 
> our original pick too.
> 
> Uploaded is part of a draft version of 2.4 base kernel patch - we're

> cleaning up 2.6 patches at this moment. It basically adds a new
export 
> flag (NFSEXP_FOLOCK - note that ex_flags is an int but is currently
only 
> defined up to 16 bits) so nfs-util and kernel can communicate.
> 
> The nice thing about this approach is the recovery part - the
take-over 
> server can use the counter part command to export and set grace
period 
> for one particular interface within the same system call.
> 
> -- Wendy


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
