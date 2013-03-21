Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:45867 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751891Ab3CUAdp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Mar 2013 20:33:45 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Haynes, Tom" <Tom.Haynes@netapp.com>
CC: Christopher T Vogan <cvogan@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        nfsv4 list <nfsv4@ietf.org>, Neil Brown <neilb@suse.de>
Subject: Re: What is NFSv4 READDIR doesn't return a filehandle....
Date: Thu, 21 Mar 2013 00:33:44 +0000
Message-ID: <1363826022.4790.89.camel@leira.trondhjem.org>
References: <OF5A466E86.6A319FE3-ON87257B34.007C6188-86257B34.007C87C8@us.ibm.com>
	 <39CEE4C6-A2A5-4D16-84BD-E1610FE67F36@netapp.com>
In-Reply-To: <39CEE4C6-A2A5-4D16-84BD-E1610FE67F36@netapp.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-03-20 at 23:53 +0000, Haynes, Tom wrote:
> Please note that I have cc'ed the NFSv4 list over at the IETF.
> 
> On Mar 20, 2013, at 3:40 PM, Christopher T Vogan <cvogan@us.ibm.com> wrote:
> 
> > All,
> > 
> > Sorry for this late posting, a coworker was made aware of this thread 
> > recently and
> > has these replies to make.  Our server implementation is the one being
> > complained about in this thread.
> > 
> > 
> > Quoted text is from various entries in this forum.
> > 
> > 
> > Neil Brown:
> > ===========
> >> Just a thought: while coping with broken servers would not be a good 
> > path to
> >> follow, detecting protocol violations and reporting an error might be...
> >> should the NFS client treat a missing filehandle and a malformed reply?
> > 
> > The server is allowed to remove an attribute bit from an entry in the 
> > readdir
> > reply, this is not "broken" nor is the reply "malformed".  The lack of a 
> > filehandle in the reply is deterministic.
> > 
> > 
> > 
> > Trond Myklebust:
> > ================
> >>> A customer has come across a server which does not return the 
> > filehandle
> >>> information (is that allowed?).
> >> 
> >> The filehandle attribute is a mandatory attribute according to RFC3530, 
> > so I believe that the answer is "no".
> > 
> > Mandatory is described in RFS 3530 as that the server must return the 
> > attribute
> > on a GETATTR.  (Section 5, page 36).  There is nothing saying that it is
> > mandatory to return on a READDIR.  Our server will return the filehandle
> > on a LOOKUP/GETATTR every time.
> 
> 
> 
> GETATTR and READDIR both return attributes. To be precise, they return
> a fattr4.
> 
> Looking at Section 15.26.4 (roughly pages 277-279 of the most recent copy)
> of 3530bis (3530 is on the way to being replaced), READDIR states:
> 
>    The READDIR operation retrieves a variable number of entries from a
>    filesystem directory and returns client requested attributes for each
>    entry along with information to allow the client to request
>    additional directory entries in a subsequent READDIR.
> ...
>    On successful return, the server's response will provide a list of
>    directory entries.  Each of these entries contains the name of the
>    directory entry, a cookie value for that entry, and the associated
>    attributes as requested.  The "eof" flag has a value of TRUE if there
>    are no more entries in the directory.
> 
> Any client implementation has no way to request that any server implementation
> return the filehandle because the filehandle is not an attribute which
> can be requested. I.e., it is mandatory.
> 
> If the intent was to allow the server to not return a filehandle for READDIR but to
> allow it to return one for GETATTR, then it would have been made
> OPTIONAL.
> 
> Whether or not the client used to work with such a server implementation
> or not is immaterial as far as standard compliance is concerned.
> 
> If you like, we can clean up the corresponding language in 3530bis to
> explicitly state that REQUIRED attributes are indeed required whether
> in response to GETATTR or READDIR.

It might rather be useful to add language to point out that the
"filehandle" attribute SHOULD NOT be used for the GETATTR case. We have
GETFH, and AFAICR, all the language around referrals etc is written with
the assumption that clients _won't_ use GETATTR to retrieve the
filehandle.

Ditto for the case of "rdattr_error", which makes absolutely no sense
whatsoever in a GETATTR request.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
