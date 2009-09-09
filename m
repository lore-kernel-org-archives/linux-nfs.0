Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:37658 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175AbZIIWSm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Sep 2009 18:18:42 -0400
Cc: Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        steved@redhat.com, linux-nfs@vger.kernel.org
Message-Id: <D2B488FA-2630-4355-8E3B-FE1243E4C3AE@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1252525327.8722.81.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st part)
Date: Wed, 9 Sep 2009 18:18:11 -0400
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net> <20090805144540.12866.22084.stgit@matisse.1015granger.net> <20090805174811.GB9944@fieldses.org> <DBAD3130-0633-414A-914B-CC2F15ABB219@oracle.com> <20090805181545.GF9944@fieldses.org> <7330021D-C95A-463D-8D18-29453EF185BC@oracle.com> <1249507356.5428.11.camel@heimdal.trondhjem.org> <D503383F-3D52-4F93-B850-AFE84316435C@oracle.com> <1249515004.5428.34.camel@heimdal.trondhjem.org> <20090909142945.755da393@tlielax.poochiereds.net> <1252521599.8722.53.camel@heimdal.trondhjem.org> <20B7C2F0-E566-4292-91E9-41A3FA6C9D4C@oracle.com> <1252525327.8722.81.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sep 9, 2009, at 3:42 PM, Trond Myklebust wrote:
> On Wed, 2009-09-09 at 15:17 -0400, Chuck Lever wrote:
>> On Sep 9, 2009, at 2:39 PM, Trond Myklebust wrote:
>> The old statd still exists in nfs-utils.  The new statd is an  
>> entirely
>> separate component.  Distributions can continue to use the old statd
>> as long as they want.  This is a red herring.
>
> Bullshit. If they are adding IPv6 support, then they will have to
> upgrade at some point.

I don't see a problem with a distribution upgrade using old statd and  
a fresh install using new statd.  You have to install a lot of new  
components to get NFS/IPv6 support.  It's not like the only thing that  
needs to change is statd.  People will install a new distribution to  
get IPv6 support.  With so many simple ways to install from scratch,  
the days of someone upgrading just a few pieces of an old system to  
get a new feature, especially one as extensive as NFS/IPv6, are long  
gone.

I don't hear a lot of distributors objecting to this idea.

And you have never clearly answered why it wouldn't be enough to add a  
little code to convert the current on-disk format to sqlite3 when  
upgrading to the new statd, if upgradability is truly an important  
requirement.  Possibly this is because it eliminates the only real  
technical objection you have to using sqlite3 here.

>>> Simplicity is another reason. WTF do we need a full SQL database,  
>>> when
>>> all we want to do is store 2 pieces of data (a hostname and a  
>>> cookie)?
>>> It isn't as if this has been a major problem for us previously.
>>
>> Because we are not storing just a hostname and a cookie.  We are
>> storing several different data items for each host, and we need to
>> search over the records, and provide uniqueness constraints, and
>> handle data conversion (for binary data like the cookie, for string
>> data like the hostname, and for integers, like the prog/vers/proc
>> tuple).  We need to store them durably on persistent storage to have
>> some protection against crashes.  These are all things that an
>> embedded database can do well, and that we therefore don't have to
>> code ourselves.
>
> Speaking of red herrings. Why are we adding all this crap?
>
> This is a legacy filesystem! We shouldn't not be rewriting NLM/NSM  
> from
> scratch, just add minimal support for IPv6.

You and Bruce brought up a number of work items related to statd,  
including having distinct statd behavior for remotes who are clients  
and remotes who are servers.  Tom Talpey suggested we needed to send  
multiple SM_NOTIFY requests to each host, and use TCP to do it when  
possible, and you even specifically encouraged me to read his  
connectathon presentation on this.  If Asian countries are driving the  
IPv6 requirement, why wouldn't they want IDN support as well?   
Interoperable NFS/IPv6 support requires TI-RPC.  Plus, NFS/IPv6  
practically requires multi-homed NLM/NSM support -- see Alex's RFC  
draft for details on that.

Which would you like me to drop?

Let me also point out that old statd is already broken in a number of  
ways, and I certainly haven't heard a lot of complaints about it.  Our  
client NLM has sent "0" as our NSM state number for years, for  
example.  Thus I hardly think there is a lot of risk in making changes  
here.  It can only get better.

>>>>>> In any event, it's not just sync(2) that is a problem.  sync(2)  
>>>>>> by
>>>>>> itself is a boot performance problem, but it's the combination of
>>>>>> rename and sync that is known to be especially unreliable during
>>>>>> system crashes.  Statd, being a crash monitor, shouldn't depend  
>>>>>> on
>>>>>> rename/sync to maintain persistent data in the face of system
>>>>>> instability.  I'd call that a real reason to use something more
>>>>>> robust.
>>>>>
>>>>> What are you talking about? Is this about the truncate + rename
>>>>> issue
>>>>> leaving empty files upon a crash?
>>>>> That issue is solved trivially by doing an fsync() before you
>>>>> rename the
>>>>> file. That entire discussion was about whether or not existing
>>>>> applications should be _required_ to do this kind of POSIX  
>>>>> pedantry,
>>>>> when previously they could get away without it.
>>>>>
>>>>> IOW: that issue alone does not justify replacing the current
>>>>> simple file
>>>>> based scheme.
>>>>>
>>>>
>>>> There are other reasons, not to use the simple file-based scheme
>>>> too...
>>>>
>>>> Internationalized domain names will be easier to deal with via
>>>> sqlite3,
>>>> for instance.
>>>
>>> Please explain...
>>
>> IPv6 is used in Asia, where they almost certainly need to use non-
>> ASCII characters in their hostnames.  Internationalized domain names
>> are stored in double-wide character sets.  To provide reliable  
>> support
>> for IDNs in statd, we will have to guarantee somehow that we can  
>> store
>> an IDN as a file name (if we want to stay with the current scheme),  
>> no
>> matter what file system is used for /var.
>
> So, what's stopping us? These are POSIX filesystems. They can store  
> any
> filename as long as it doesn't contain '/' or '\0'.

IDNs are UTF16.  /var therefore has to support UTF16 filenames; either  
byte in a double-byte character can be '/' or '\0'.  That means the  
underlying fs implementation has to support UTF16 (FAT32 anyone?), and  
the system's locale has to be configured correctly.  If we decide not  
to depend on the file system to support UTF16 filenames, then statd  
has to be intelligent enough to figure out how to deal with converting  
UTF16 hostnames before storing them as filenames.  Then, we have to  
teach matchhostname() and friends how to deal with double-byte  
character strings...

Or we just tell sqlite3 that this is a double-byte character string,  
and let it handle the collation and on-disk storage details for us.

The point is, this is yet another detail we have to either worry about  
and open code in statd, or we can simply rely on what's already  
provided in sqlite3.  No one, repeat NO ONE, is arguing that you can't  
implement these features without sqlite3.  My argument is that we  
quickly bury a whole bunch of details if we use sqlite3, and can then  
focus on larger issues.  That's the prime goal of software layering  
with libraries.

We can open code any or all of statd.  In fact the current statd open  
codes RPC request creation in socket buffers rather than using glibc's  
RPC API, and I think we agree that is not an optimal solution.  The  
question is: should we duplicate code and bugs by open coding statd's  
RPC and data storage?  Or should we pretend to be modern software  
engineers, and use widely used and known good code that other people  
have written already to handle these details?

>> What's more, multi-homed host support will need to store multiple
>> records for the same hostname.  The mon_name is the same, but my_name
>> is different, for each of these records.  So we could do that by
>> adding more than one line in each hostname file, but it's also a
>> simple matter to set this up in SQL.
>>
>> When we want to have statd remember things like multiple addresses  
>> for
>> the same hostname, or whether the remote is a client or server, we
>> will need to make more adjustments to the files.
>>
>> As we get more and more new requirements, why lock ourselves into the
>> current on-disk format?  Using statd means we can store new fields  
>> and
>> new records without any backwards-compatibility issues.  It's all
>> handled by the database code.  So, we can think about the high level
>> problem of getting statd to behave correctly rather than worry about
>> the details of exactly how we are going to get the next data item
>> stored in our current files in a backward compatible way.
>
> Again. This is a legacy filesystem. Why are we adding requirements?

Maybe you should ask the people who are requesting NFS/IPv6 from Red  
Hat and other distributors.  Or ask yourself why we would add an  
engine to allow NFSv2 to shift authentication flavors without  
remounting, since NFSv2 is a legacy filesystem.  Or ask why you think  
we should add support to statd to recognize the difference between  
remote clients and servers, if this is a legacy filesystem.

I don't object to any of those work items, but I do have trouble with  
you dropping in and saying "why diddle a legacy file system" when  
clearly that is not a show stopper in these other cases.

>>>> Certainly we could code this up ourselves, but what's the benefit  
>>>> to
>>>> doing that when we have a perfectly good data storage engine
>>>> available?
>>>
>>> Why change something that works???? Rewriting from scratch is _NOT_
>>> the
>>> Linux way, and has usually bitten us hard when we've done it.
>>
>> Because we are adding a bunch of new feature requirements.
>> Internationalized domain names, multi-homed host support, IPv6 and  
>> TI-
>> RPC, fast boot times, keeping better track of remote host addresses,
>> keeping track of which remotes are clients and which are servers, and
>> support for sending notifications via TCP all require significant
>> modifications to this code base.
>>
>> At some point you have to look at the code you have, and decide it's
>> simply not going to be adequate, going forward.
>>
>>> The 2.6.19 rewrite of the kernel mount code springs to mind...
>>
>> One can just as easily argue that we've been bitten hard precisely
>> because we've let things rot, or because we have inadequate testing
>> for these components.
>>
>> Another red herring, and especially annoying because you've known I
>> was rewriting statd for months.  Only now, when I'm done, do you say
>> "rewriting is not the Linux way."
>
> I have _NEVER_ agreed to a rewrite of the storage formats. You sprang
> this crap on me a month ago, and I made my feelings quite clear then.

"Rewriting is not the Linux way" is not the same as saying you don't  
want to change storage formats.  Don't change the subject.

The idea that "the Linux way" is the best and only way is ridiculous  
on its face, anyway.  I mean, what do you expect when we have no  
requirements and specification process, no formal testing, C coding  
style conventions based on 20-year old coding practices, a hit-or-miss  
review process that relies more on reviewers' personal preferences  
than any kind of standards, no static code analysis tools, no defect  
metrics or bug meta-analysis tools, kernel debuggers are verboten, a  
combative mailing list environment, and parts of our knowledge base  
and team history are lost every time a developer leaves (in this case,  
Olaf and Neil)?  It's no wonder we never change anything unless  
absolutely necessary!

You told me to implement IPv6 support in statd.  Now you are spitting  
on what I worked out without any guidance from you because you're too  
busy working on IETF standards and NFSv4.1 to bother discussing  
"legacy" code, other than to say "ewe!".  Just how should I react to  
that, pray tell?

Clearly you do not want to admit that even "minimal" IPv6 support is a  
significant effort, especially given how far behind the Linux RPC and  
NLM/NSM implementations are.  Yelling at me, throwing a bunch of  
generic objections up, and calling my code "crap" is not going to make  
the problem any simpler.

Cooperating with me to get your way and giving specific and  
constructive criticism will go a lot farther than your aggressive and  
disrespectful attitude and obnoxious tone.  I will happily sit down  
and discuss this with you in a rational tone, but I will no longer  
tolerate your unwarranted harassment on a public mailing list.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



