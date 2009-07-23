Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43586 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751868AbZGWSLs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Jul 2009 14:11:48 -0400
Cc: erveith@de.ibm.com, linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Message-Id: <2CFD9099-9CE1-479D-99D0-80C4E5FA58F4@netapp.com>
From: Andy Adamson <andros@netapp.com>
To: Rick Macklem <rick@snowhite.cis.uoguelph.ca>
In-Reply-To: <200907231510.LAA43979@snowhite.cis.uoguelph.ca>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: nfs4 write delegation status
Date: Thu, 23 Jul 2009 14:11:46 -0400
References: <200907231510.LAA43979@snowhite.cis.uoguelph.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jul 23, 2009, at 11:10 AM, Rick Macklem wrote:

>>> I really don't want to enable write delegations until we figure  
>>> out how
>>> to enforce them correctly against local (non-nfs) users of the  
>>> exported
>>> filesystem as well.  In addition to breaking delegations on read  
>>> opens,
>>> that means breaking delegations or doing a cb_getattr on  
>>> operations like
>>> stat.
>>
>> do you know whether there are local FS where the maintainers at  
>> least plan
>> to incorporate delegations?
>
> I'm not a Linux guy, so I'm not familiar with the internal  
> structure, but...
> in general, I don't think the problem is with local file systems.  
> Usually
> the problem is with local system call access. For example, if a
> process running locally on the server opens a file, the delegation  
> should
> be recalled, so that changes done locally on the client get flushed  
> back
> to the server. Also, a write delegation allows a client to do byte  
> range
> locking locally in the client, so the write delegation needs to be
> recalled before anything gets a byte range lock locally in the server.

The delegation implementation on the Linux server uses the vfs lease  
subsystem, and so is integrated with local access - conflicting opens  
done locally do recall delegations.  But the last time I looked, the  
lease subsystem is not complete as it doesn't recall leases (nor  
delegations) on remove, rename, etc. Another problem is that while  
write delegations improve performance for certain workloads, they kill  
performance for others.

-->Andy

>
>
> A Samba server running in the nfs server would be doing "local" ops
> for the purpose of this discussion. (I'm not sure if Samba goes as far
> as doing Open/Share locks for clients?)
>
> rick
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

