From: Sam Falkner <Sam.Falkner@Sun.COM>
Subject: Re: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Sun, 23 Jul 2006 09:47:36 -0600
Message-ID: <85DB3DBD-31B4-4F71-AEFB-5919DC072AD6@Sun.COM>
References: <C98692FD98048C41885E0B0FACD9DFB8023DF6B9@exnane01.hq.netapp.com>
	<20060721181058.GA17169@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; delsp=yes; charset=US-ASCII
Cc: Lisa Week <Lisa.Week@Sun.COM>, nfsv4@ietf.org, nfs@lists.sourceforge.net,
	"Noveck, Dave" <Dave.Noveck@netapp.com>,
	Spencer Shepler <spencer.shepler@Sun.COM>, "Pawlowski,
	Brian" <beepy@netapp.com>, Andreas Gruenbacher <agruen@suse.de>
Return-path: <nfsv4-bounces@ietf.org>
In-reply-to: <20060721181058.GA17169@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>


On Jul 21, 2006, at 12:10 PM, J. Bruce Fields wrote:

> On Fri, Jul 21, 2006 at 11:10:04AM -0400, Noveck, Dave wrote:
>>> Rethinking, it would be preferable to have the ACL specification
>>> specify requirements, and have the algorithms serve as examples.
>>
>> I think the requirements that the algorithms are intended to address,
>> would be helpful in understanding, whether the algorithms are
>> examples or are mandatory.
>
> Yes.  My point wasn't necessarily that they should not be mandatory
> (though I think they probably shouldn't be--I'm not yet convinced
> they're actually correct), but that we need clarified whether they're
> mandatory or not, and what requirements they're meant to meet,  
> before we
> can evaluate them properly.

If you have any concerns about their correctness, please let me  
know.  As of now, there has not been a single example showing a flaw  
in them.  I realize this is difficult without having the requirements  
listed explicitly -- this will be remedied very soon.

>> I think this would complicate understanding and review.  Even if
>> the algorithms are examples and not mandatory, I would imagine
>> they would be helpful in understanding the requirements and their
>> implications, and if they are helpful, they should be in the spec,
>> with an indication that they are illustrative and not mandatory.
>
> But I don't care whether they're incorporated by reference or copying.

Issue 93 is tracking this.  Anyone else having opinions should voice  
them.

- Sam

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
