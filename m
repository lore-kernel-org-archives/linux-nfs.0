From: Peter Staubach <staubach@redhat.com>
Subject: Re: [patch 2/3] knfsd: avoid overloading the CPU scheduler with enormous
 load averages
Date: Tue, 13 Jan 2009 17:35:33 -0500
Message-ID: <496D1735.40903@redhat.com>
References: <20090113102633.719563000@sgi.com> <20090113102653.664553000@sgi.com> <496CA61C.5050208@redhat.com> <496D1294.1060407@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS ML <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:47714 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753305AbZAMWfh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Jan 2009 17:35:37 -0500
In-Reply-To: <496D1294.1060407-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greg Banks wrote:
> Peter Staubach wrote:
>   
>> Greg Banks wrote:
>>     
>>> [...]
>>> Testing was on a 4 CPU 4 NIC Altix using 4 IRIX clients, each with 16
>>> synthetic client threads simulating an rsync (i.e. recursive directory
>>> listing) workload[...]
>>>
>>> Profiling showed schedule() taking 6.7% of every CPU, and __wake_up()
>>> taking 5.2%.  This patch drops those contributions to 3.0% and 2.2%.
>>> Load average was over 120 before the patch, and 20.9 after.
>>> [...]
>>>       
>> Have you measured the impact of these changes for something
>> like SpecSFS?
>>     
>
> Not individually.  This patch was part of some work I did in late
> 2005/early 2006 which was aimed at improving NFS server performance in
> general.  I do know that the server's SpecSFS numbers jumped by a factor
> of somewhere over 2x, from embarrassingly bad to publishable, when
> SpecSFS was re-run after that work.  However at the time I did not have
> the ability to run SpecSFS myself, it was run by a separate group of
> people who had dedicated hardware and experience.  So I can't tell what
> contribution this particular patch made to the overall SpecSFS
> improvements.  Sorry.

That does sound promising though.  :-)

It would be interesting to get some better information regarding
some of the measurable performance ramifications such as SFS
though.  The Linux NFS server has not had much attention paid to
it and I suspect that it could use some work in the performance
area.

    Thanx...

       ps
