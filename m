From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
 PATCH 3/3] knfsd: Modify write_ports to use svc_find_xprt service
Date: Thu, 11 Oct 2007 00:11:26 -0500
Message-ID: <C3331AAE.3C378%tom@opengridcomputing.com>
References: <20071011034608.GC6684@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Greg Banks <gnb@sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
	NeilBrown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfqCF-0004Jf-PO
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 22:02:55 -0700
Received: from mail.es335.com ([67.65.19.105])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfqCK-0005Z6-I6
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 22:03:00 -0700
In-Reply-To: <20071011034608.GC6684@fieldses.org>
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


Bruce:

What's the most efficient way for you to accept fixes/changes? I've been
going incremental because it's easy on me :-). Is this the best option for
you?

Regarding patch #6, I think the svc_find_xprt API _may_ be ok, but the
implementation was bogus (sorry). I _think_ the implementation is fixed in
the latest incremental. Greg can confirm.

WRT the suggestions below, I'll make those mods and test them tomorrow.

Thanks,
Tom

On 10/10/07 10:46 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Oct 11, 2007 at 01:00:58PM +1000, Neil Brown wrote:
>> On Wednesday October 10, tom@opengridcomputing.com wrote:
>>> if (sscanf(buf, "%15s %4d", transport, &port) == 2) {
>> 
>> We should give a bit of thought to this parsing and future expansion.
>> Suppose we did want to pump more information into the kernel as has
>> been suggested (e.g. local IP address), we would want this code to
>> handle the new format correctly, probably by failing.
>> 
>> So maybe we really want
>> 
>>> if (sscanf(buf, "%15s %4d%c", transport, &port, &nl) == 2
>>            && nl == '\n') {
>> 
>> or something like that???
>> 
>> BTW, I'm fairly happy with the state of this patch set and suggest
>> that we aim for 2.6.24-rc1.  I still want to read through the final
>> code with all patches applied, but I should be able to find time for
>> that in the next month or so.  I don't expect any significant issues.
> 
> It seems OK to me, and it would be nice to get this batch in and have
> just the rdma stuff left to merge in 2.6.25.
> 
> But we're very short for time, and it appears that there's still some
> work to be done.  Certainly any user interfaces need to be sorted out,
> as we'll be stuck with them....
> 
> Other work to be done: these incremental fixes are helpful for reviewers
> like Greg who are keeping close watch on the process, but we need to
> submit a patch series that shows our changes with perfect hindsight, so
> we need to combine these with the previous patches.  I did this with the
> most recent two of Tom's 7-patch series; result here:
> 
> git://linux-nfs.org/~bfields/linux.git server-xprt-switch
> 
> I didn't apply patch #6 since Greg still had comments, and I haven't
> applied the most recent fixes.
> 
> If this isn't all ready by Friday (OK, maybe Monday) then I think we're
> out of time.
> 
> --b.



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
