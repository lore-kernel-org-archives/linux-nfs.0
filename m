From: "Noveck, Dave" <Dave.Noveck@netapp.com>
Subject: RE: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Tue, 18 Jul 2006 21:48:54 -0400
Message-ID: <C98692FD98048C41885E0B0FACD9DFB8029EFFAD@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: Lisa Week <Lisa.Week@Sun.COM>, nfsv4@ietf.org,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@Sun.COM>, "Pawlowski,
	Brian" <beepy@netapp.com>, Andreas Gruenbacher <agruen@suse.de>
Return-path: <nfsv4-bounces@ietf.org>
To: "Sam Falkner" <Sam.Falkner@Sun.COM>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

It seems like this is what most users would want.  It doesn't seem to=20
match what is specified in section 3.16.6.3 of draft-03.  That says
the acl is modified when you change the mode.

What does solaris do if you do a chmod specifying a numeric mode
whose value is the same as would be set by doing a chomod +s?  Does
that change the ACL? =20

-----Original Message-----
From: Sam Falkner [mailto:Sam.Falkner@Sun.COM]=20
Sent: Tuesday, July 18, 2006 6:09 PM
To: Noveck, Dave
Cc: J. Bruce Fields; Lisa Week; nfsv4@ietf.org;
nfs@lists.sourceforge.net; Spencer Shepler; Pawlowski, Brian; Andreas
Gruenbacher
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
draft-ietf-nfsv4-acls-00 not ready

On Jul 16, 2006, at 7:10 AM, Noveck, Dave wrote:

> What does Solaris do about chmod +s?  Does it modify the ACL?

No -- chmod +s leaves the ACL (if any) alone, and only affects the
setuid bit.

- Sam

> -----Original Message-----
> From: Sam Falkner [mailto:Sam.Falkner@Sun.COM]
> Sent: Saturday, July 15, 2006 9:56 AM
> To: J. Bruce Fields
> Cc: Lisa Week; nfsv4@ietf.org; nfs@lists.sourceforge.net; Spencer=20
> Shepler; Pawlowski, Brian; Andreas Gruenbacher
> Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction /=20
> mask,draft-ietf-nfsv4-acls-00 not ready
>
> On Jul 11, 2006, at 9:46 AM, J. Bruce Fields wrote:
>
>> On Tue, Jul 11, 2006 at 08:29:21AM -0400, Sam Falkner wrote:
>>> That's not how Solaris works either.  Sorry, I should have explained

>>> it better.  In Solaris using POSIX-draft ACLs, chmod() changes both=20
>>> the group permissions and the mask, simultaneously.  I now=20
>>> understand
>
>>> why you were hesitant to have chmod affect the group permissions,=20
>>> but
>
>>> having it affect both mask and group solves both problems.
>>
>> I think you're missing the point of his example.  The point is that a

>> chmod-using application may expect the sequence chmod(600) chmod
>> (664) on
>> a file with mode 664 to be a no-op.
>>
>> But if chmod() changes both group and mask bits ("owning group" and=20
>> "group file class" bits) then this sequence isn't a no-op any more in

>> his example.  It gives GROUP@ write permissions.
>
> Okay, understood.
>
>> So Andreas is trying to ensure the property that any sequence of=20
>> chmod's that leaves the mode bits the same also leaves the ACL the=20
>> same.  I agree that that's a nice property.
>
> Perhaps, but I think having chmod unable to set the mode to be a much=20
> more undesirable property, to put it mildly.
>
>> What I'm not convinced of yet is that this is really worth caring=20
>> about much.  Is this common application behavior?  Have there been=20
>> complaints about this from people using Solaris's ACLs?
>
> I did some more research, and found that the Solaris chmod() system=20
> call does pretty much what Linux does -- the group permissions of
> chmod() affect the mask, not the group permission bits.  =20
> Originally, the
> chmod command did the chmod() system call, and not much else.
>
> There were many complaints about this.  So many that the chmod command

> line was changed to do the chmod() system call, and then, in the=20
> presence of an ACL, fix the permission bits.  In other words, the bug=20
> was fixed.
>
> I have found no complaints about the current Solaris behavior, where=20
> chmod affects group permissions.
>
> - Sam
>
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www1.ietf.org/mailman/listinfo/nfsv4
>
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www1.ietf.org/mailman/listinfo/nfsv4

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
