From: Sam Falkner <Sam.Falkner@Sun.COM>
Subject: Re: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Thu, 20 Jul 2006 16:57:10 -0600
Message-ID: <00D8565E-6887-4214-A18B-325921051BBB@Sun.COM>
References: <C98692FD98048C41885E0B0FACD9DFB8029EFFAD@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; delsp=yes; charset=US-ASCII
Cc: Lisa Week <Lisa.Week@Sun.COM>, nfsv4@ietf.org,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@Sun.COM>, "Pawlowski,
	Brian" <beepy@netapp.com>, Andreas Gruenbacher <agruen@suse.de>
Return-path: <nfsv4-bounces@ietf.org>
In-reply-to: <C98692FD98048C41885E0B0FACD9DFB8029EFFAD@exnane01.hq.netapp.com>
To: "Noveck, Dave" <Dave.Noveck@netapp.com>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Jul 18, 2006, at 7:48 PM, Noveck, Dave wrote:

> It seems like this is what most users would want.  It doesn't seem to
> match what is specified in section 3.16.6.3 of draft-03.  That says
> the acl is modified when you change the mode.

Right -- see below...

> What does solaris do if you do a chmod specifying a numeric mode
> whose value is the same as would be set by doing a chomod +s?  Does
> that change the ACL?

Sorry, I misunderstood your earlier question -- I was testing against  
POSIX-draft ACLs, and not NFSv4 ACLs.  In the case of NFSv4 ACLs (on  
ZFS), it does change the ACL, whether you use "+s" or "4xxx".  In my  
test, it added a mask ACE for the supplemental user I had added  
before, even though the mask didn't really mask anything in this case.

As you pointed out, chmod doesn't necessarily have to modify the ACL  
to set the setuid bit in the mode, unless the mode requires changes  
to the ACL for POSIX conformance.  The mode might require changing  
the ACL more times than is obvious, but the ACL specification  
shouldn't require unnecessary changes to the ACL...

Here's an idea.  It's not an original idea, it's one that Bruce  
proposed last April, and unfortunately his comments went unanswered  
(mea culpa).

The current ACL spec, in the minorversion1 draft and in the previous  
ACL drafts, rigorously specifies mode/ACL interactions by specifying  
algorithms.  Bruce had the comment that the spec read as though the  
algorithm was mandatory.

Rethinking, it would be preferable to have the ACL specification  
specify requirements, and have the algorithms serve as examples.  Or,  
rewrite the sections as requirements, and release algorithms outside  
the minorversion1 draft, possibly through one or more informational  
RFCs.  This would shorten the minorversion1 draft, without  
invalidating the existing semantics.

We'll try to have an initial draft of the ACL parts of the  
minorversion1 document on August 7.  I'll also add an issue to nfs4- 
editor.org.

- Sam

(Read on if you're interested in implications.)

This would make it possible to craft different algorithms that can  
still meet the ACL spec in minorversion1.  Take this example single- 
ACE ACL as a starting point:

EVERYONE@:read_data/execute::ALLOW

and a starting mode of 0555.

given a setattr of mode 4555 and no ACL, the new mode MUST become  
4555, and the resulting ACL could legally be any of the following:

(current algorithm)
EVERYONE@:::ALLOW
OWNER@:write_data/append_data::DENY
OWNER@:read_data/write_xattr/execute/write_attributes/write_acl/ 
write_owner::ALLOW
GROUP@:write_data/append_data::DENY
GROUP@:read_data/execute::ALLOW
EVERYONE@:write_data/append_data/write_xattr/write_attributes/ 
write_acl/write_owner::DENY
EVERYONE@:read_data/read_xattr/execute/read_attributes/read_acl/ 
synchronize::ALLOW

or

(simple ALLOW-only-when-possible algorithm)
OWNER@:read_data/execute::ALLOW
GROUP@:read_data/execute::ALLOW
EVERYONE@:read_data/execute::ALLOW

or

(unchanged -- this algorithm is smart enough to see that no change  
was necessary)
EVERYONE@:read_data/execute::ALLOW


_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
