Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:50752 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645Ab2HJUeA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Aug 2012 16:34:00 -0400
Subject: Re: NFS: Treat NFS4ERR_CLID_INUSE as a fatal error
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120810201348.GB17985@fieldses.org>
Date: Fri, 10 Aug 2012 16:33:46 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        David Noveck <david.noveck@emc.com>
Message-Id: <12DB2C80-31EB-4317-B1E7-96620A8F7374@oracle.com>
References: <20120809183557.GA10591@fieldses.org> <53272628-CC34-4279-AA69-CD31B86672D5@oracle.com> <20120809193743.GD10591@fieldses.org> <20120809203838.GA11538@fieldses.org> <24601061-1606-4A0A-940E-FDAFD1A2A2BB@oracle.com> <39FE3A39-4EB2-4F9F-908F-645C79B30E0F@oracle.com> <20120809211340.GB11538@fieldses.org> <6575B2FD-CCE4-40D5-9CBA-82681EC20E17@oracle.com> <20120809213838.GC11538@fieldses.org> <B28F4673-3650-4BA9-ADDA-F9A8E62A0499@oracle.com> <20120810201348.GB17985@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 10, 2012, at 4:13 PM, J. Bruce Fields wrote:

> On Fri, Aug 10, 2012 at 03:38:30PM -0400, Chuck Lever wrote:
>> 
>> On Aug 9, 2012, at 5:38 PM, J. Bruce Fields wrote:
>> 
>>> On Thu, Aug 09, 2012 at 05:29:47PM -0400, Chuck Lever wrote:
>>>> 
>>>> On Aug 9, 2012, at 5:13 PM, J. Bruce Fields wrote:
>>>>> The server could just compare principal strings (and ignore
>>>>> pseudoflavors) in the gss case.
>>>> 
>>>> Barring a correction about how GSS Kerberos principals work, I think that's the correct approach.
>>> 
>>> I also don't know if principals produced by other mechanisms are going
>>> to be comparable.  Of course that's a bit academic given that kerberos
>>> is the only mechanism for the forseeable future.
>> 
>> Agreed, I would expect this to work only for pseudoflavors that share the same type of principal.
>> 
>> Let me be sure I understand... I think the text of RFC 3530bis allows this implementation choice, but you are suggesting below that such an implementation may allow an attack.  Does this concern warrant a change to RFC 3530bis or 5661?  Should we bring this up on nfsv4@ietf.org?
> 
> This should be all completely settled in 4.1.  It's 4.0 that I'm
> confused by.

Then 3530bis only.

> What do you need the client to be able to do?  Does it need to be able
> to perform setclientid's on the same client with different security
> flavors?

The problem is what client implementations really do, not what they "should" do.  They should use a single SETCLIENTID with one flavor.  Linux currently doesn't, and I'm guessing others are in the same boat.  Since clients use different id strings for each flavor, the problem is avoided, but that isn't desirable client behavior.

My concern above is with the spec.  If it allows insecure implementations, maybe we should fix the spec.

> In this particular case (mount/umount with one flavor, then mount/umount
> with another), maybe the client should destroy the client state (with an
> "I rebooted" setclientid) on the first umount?  (I thought you had
> patches that did that?)

OK, I didn't notice that you were unmounting between the tests.  3.5 and before did update the boot verifier after the last mount of a server goes away, but that's also not desirable behavior.  So I guess 3.6 also has my patch which makes the NFS client use the same boot verifier until it reboots, as God and the authors of 3530 intended?

I think we agree that, whether the Linux server is compliant with what's currently in 3530bis or not, it's the NFS client changes in 3.6 that "introduced the regression" and should be fixed.  If you change the client to add the flavor and pseudoflavor name to the nfs_client_id4.id string, does that fix the regression satisfactorily?

Maybe we should just revert those two and try again in 3.7.

> --b.
> 
>> 
>>> 
>>>>> If the intention is to ensure that a clientid can't be "hijacked" by
>>>>> someone malicious, then you don't want to allow a krb5 setclientid to
>>>>> blow away a clientid established with krb5i.  (If sending the
>>>>> setclientid with krb5i indicates the client wants protection against
>>>>> attacks which replace the body of the rpc, then a later krb5 setclientid
>>>>> should be rejected, since it could be the product of such an attack.)
>>>> 
>>>> If the client wants to avoid hijacking, it should start out with krb5i, as is recommended in the Security Considerations section of 3530(bis).
>>>> 
>>>> The intention of 3530(bis) is that one client instance uses just one nfs_client_id4.id string.  A client that attempts to change flavors on its SETCLIENTID/RENEW operations in mid-journey, on purpose, seems a little schizophrenic.  I can't think of a good reason it should do this.
>>> 
>>> You don't know it's the same client any more.  The attack is:
>>> 
>>> 	client sends setclientid with krb5i.
>>> 
>>> 	client later sends some other rpc with krb5.
>>> 
>>> 	attacker intercepts that operation, takes the rpc header, strips
>>> 	out the body, and replaces the body by a setclientid operation
>>> 	destroying the client's state.
>>> 
>>> Since krb5 only protects the header, the server can't tell that's what's
>>> happened.
>> 
>> -- 
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>> 
>> 
>> 
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




