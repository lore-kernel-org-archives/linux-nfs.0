From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs4 write delegation status
Date: Fri, 24 Jul 2009 14:44:29 -0400
Message-ID: <20090724184429.GA16811@fieldses.org>
References: <200907231510.LAA43979@snowhite.cis.uoguelph.ca>
	<2CFD9099-9CE1-479D-99D0-80C4E5FA58F4@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, erveith@de.ibm.com, nfsv4@linux-nfs.org
To: Andy Adamson <andros@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <2CFD9099-9CE1-479D-99D0-80C4E5FA58F4@netapp.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 23, 2009 at 02:11:46PM -0400, Andy Adamson wrote:
>
> On Jul 23, 2009, at 11:10 AM, Rick Macklem wrote:
>
>>>> I really don't want to enable write delegations until we figure  
>>>> out how
>>>> to enforce them correctly against local (non-nfs) users of the  
>>>> exported
>>>> filesystem as well.  In addition to breaking delegations on read  
>>>> opens,
>>>> that means breaking delegations or doing a cb_getattr on  
>>>> operations like
>>>> stat.
>>>
>>> do you know whether there are local FS where the maintainers at  
>>> least plan
>>> to incorporate delegations?
>>
>> I'm not a Linux guy, so I'm not familiar with the internal structure, 
>> but...
>> in general, I don't think the problem is with local file systems.  
>> Usually
>> the problem is with local system call access. For example, if a
>> process running locally on the server opens a file, the delegation  
>> should
>> be recalled, so that changes done locally on the client get flushed  
>> back
>> to the server. Also, a write delegation allows a client to do byte  
>> range
>> locking locally in the client, so the write delegation needs to be
>> recalled before anything gets a byte range lock locally in the server.
>
> The delegation implementation on the Linux server uses the vfs lease  
> subsystem, and so is integrated with local access - conflicting opens  
> done locally do recall delegations.  But the last time I looked, the  
> lease subsystem is not complete as it doesn't recall leases (nor  
> delegations) on remove, rename, etc. Another problem is that while write 
> delegations improve performance for certain workloads, they kill  
> performance for others.

Are there any published results yet with real workloads?

--b.
