Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:19500 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752030Ab3CTXxt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Mar 2013 19:53:49 -0400
From: "Haynes, Tom" <Tom.Haynes@netapp.com>
To: Christopher T Vogan <cvogan@us.ibm.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        nfsv4 list <nfsv4@ietf.org>
Subject: Re: What is NFSv4 READDIR doesn't return a filehandle....
Date: Wed, 20 Mar 2013 23:53:47 +0000
Message-ID: <39CEE4C6-A2A5-4D16-84BD-E1610FE67F36@netapp.com>
References: <OF5A466E86.6A319FE3-ON87257B34.007C6188-86257B34.007C87C8@us.ibm.com>
In-Reply-To: <OF5A466E86.6A319FE3-ON87257B34.007C6188-86257B34.007C87C8@us.ibm.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please note that I have cc'ed the NFSv4 list over at the IETF.

On Mar 20, 2013, at 3:40 PM, Christopher T Vogan <cvogan@us.ibm.com> wrote:

> All,
> 
> Sorry for this late posting, a coworker was made aware of this thread 
> recently and
> has these replies to make.  Our server implementation is the one being
> complained about in this thread.
> 
> 
> Quoted text is from various entries in this forum.
> 
> 
> Neil Brown:
> ===========
>> Just a thought: while coping with broken servers would not be a good 
> path to
>> follow, detecting protocol violations and reporting an error might be...
>> should the NFS client treat a missing filehandle and a malformed reply?
> 
> The server is allowed to remove an attribute bit from an entry in the 
> readdir
> reply, this is not "broken" nor is the reply "malformed".  The lack of a 
> filehandle in the reply is deterministic.
> 
> 
> 
> Trond Myklebust:
> ================
>>> A customer has come across a server which does not return the 
> filehandle
>>> information (is that allowed?).
>> 
>> The filehandle attribute is a mandatory attribute according to RFC3530, 
> so I believe that the answer is "no".
> 
> Mandatory is described in RFS 3530 as that the server must return the 
> attribute
> on a GETATTR.  (Section 5, page 36).  There is nothing saying that it is
> mandatory to return on a READDIR.  Our server will return the filehandle
> on a LOOKUP/GETATTR every time.



GETATTR and READDIR both return attributes. To be precise, they return
a fattr4.

Looking at Section 15.26.4 (roughly pages 277-279 of the most recent copy)
of 3530bis (3530 is on the way to being replaced), READDIR states:

   The READDIR operation retrieves a variable number of entries from a
   filesystem directory and returns client requested attributes for each
   entry along with information to allow the client to request
   additional directory entries in a subsequent READDIR.
...
   On successful return, the server's response will provide a list of
   directory entries.  Each of these entries contains the name of the
   directory entry, a cookie value for that entry, and the associated
   attributes as requested.  The "eof" flag has a value of TRUE if there
   are no more entries in the directory.

Any client implementation has no way to request that any server implementation
return the filehandle because the filehandle is not an attribute which
can be requested. I.e., it is mandatory.

If the intent was to allow the server to not return a filehandle for READDIR but to
allow it to return one for GETATTR, then it would have been made
OPTIONAL.

Whether or not the client used to work with such a server implementation
or not is immaterial as far as standard compliance is concerned.

If you like, we can clean up the corresponding language in 3530bis to
explicitly state that REQUIRED attributes are indeed required whether
in response to GETATTR or READDIR.






> 
> 
> Trond Myklebust:
> ================
>> My concern is that the client can't objectively judge what constitutes a
>> valid filehandle and what does not until it tries to use it in an RPC
>> call.
> 
> Sure it can.  In the context of this discussion, if the readdir entry
> has the filehandle attribute bit off in the reply, there is no filehandle.
> 
> I would note in the scenario we sent a trace for, the Linux client had 
> a filehandle for the node in question, and "misplaced" it after a 
> readdir to the directory containing that node did not return the 
> filehandle
> for that entry.  So calling the server "broken" is objectively inaccurate.
> 
> I would also note that this problem occurred after we upgraded to RHEL 
> 6.3;
> the prior version did not have this issue, and our server did not change 
> its
> behavior.  My conclusion is that the means to obtain the filehandle was 
> either broken by the client adding logic to assume a filehandle and 
> obliterate 
> the prior value after a readdir reply chose not to return it, or 
> previously 
> had a code path to lookup the node and obtain the filehandle, and removed 
> that code path for some reason.  So again, pointing to server "breakage" 
> is objectively inaccurate.
> 
> There are many references to "brokenness" or "server bugs" in this 
> thread, and I take exception to it from a design and protocol conformance 
> point of view.
> 
> This condition is easily recoverable, as ANY missing attribute on a 
> readdir
> is with a lookup/readdir.  Our decision to not return the FH on a readdir 
> reply under certain narrow conditions is not one of convenience but of 
> limitations of some underlying filesystem types, and if "convenience" is
> to be used as an accusative, it can easily be returned to the client's 
> refusal to deal with the legal withholding of an attribute on a readdir
> reply.
> 
> 
> Signed,
> Steve Huntington
> IBM z/OS NFS
> 
> 
> Christopher Vogan
> Dept. W98 NFS Development & Test
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

