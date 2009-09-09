Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54073 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752690AbZIIXPm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2009 19:15:42 -0400
Message-ID: <4AA83715.80205@RedHat.com>
Date: Wed, 09 Sep 2009 19:15:33 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Jeff Layton <jlayton@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st
 part)
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net> <20090805144540.12866.22084.stgit@matisse.1015granger.net> <20090805174811.GB9944@fieldses.org> <DBAD3130-0633-414A-914B-CC2F15ABB219@oracle.com> <20090805181545.GF9944@fieldses.org> <7330021D-C95A-463D-8D18-29453EF185BC@oracle.com> <1249507356.5428.11.camel@heimdal.trondhjem.org> <D503383F-3D52-4F93-B850-AFE84316435C@oracle.com> <1249515004.5428.34.camel@heimdal.trondhjem.org> <20090909142945.755da393@tlielax.poochiereds.net> <1252521599.8722.53.camel@heimdal.trondhjem.org> <20B7C2F0-E566-4292-91E9-41A3FA6C9D4C@oracle.com> <1252525327.8722.81.camel@heimdal.trondhjem.org> <D2B488FA-2630-4355-8E3B-FE1243E4C3AE@oracle.com>
In-Reply-To: <D2B488FA-2630-4355-8E3B-FE1243E4C3AE@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/09/2009 06:18 PM, Chuck Lever wrote:
> On Sep 9, 2009, at 3:42 PM, Trond Myklebust wrote:
>> On Wed, 2009-09-09 at 15:17 -0400, Chuck Lever wrote:
>>> On Sep 9, 2009, at 2:39 PM, Trond Myklebust wrote:
>>> The old statd still exists in nfs-utils.  The new statd is an entirely
>>> separate component.  Distributions can continue to use the old statd
>>> as long as they want.  This is a red herring.
>>
>> Bullshit. If they are adding IPv6 support, then they will have to
>> upgrade at some point.
> 
> I don't see a problem with a distribution upgrade using old statd and a
> fresh install using new statd.  You have to install a lot of new
> components to get NFS/IPv6 support.  
What new components that are not already being installed?? 

> It's not like the only thing that needs to change is statd.  
> People will install a new distribution to get IPv6 support. 
> With so many simple ways to install from scratch, the days of someone 
> upgrading just a few pieces of an old system to get a new feature, 
> especially one as extensive as NFS/IPv6, are long gone.
I'm not sure how people could only install bits and pieces of 
nfs-utils... Even 'make install' in the git tree installs everything...

> 
> And you have never clearly answered why it wouldn't be enough to add a
> little code to convert the current on-disk format to sqlite3 when
> upgrading to the new statd, if upgradability is truly an important
> requirement.  Possibly this is because it eliminates the only real
> technical objection you have to using sqlite3 here.
The issue I would have with using sqlite3 is it would add yet another
requirement on nfs-utils... I really don't know how big sqlite3 and/or
sqlite3-devel (possibly needed for builds) packages are but it just
one more thing will be need for nfs-utils to function... 
 
> 
>>>> Simplicity is another reason. WTF do we need a full SQL database, when
>>>> all we want to do is store 2 pieces of data (a hostname and a cookie)?
>>>> It isn't as if this has been a major problem for us previously.
>>>
>>> Because we are not storing just a hostname and a cookie.  We are
>>> storing several different data items for each host, and we need to
>>> search over the records, and provide uniqueness constraints, and
>>> handle data conversion (for binary data like the cookie, for string
>>> data like the hostname, and for integers, like the prog/vers/proc
>>> tuple).  We need to store them durably on persistent storage to have
>>> some protection against crashes.  These are all things that an
>>> embedded database can do well, and that we therefore don't have to
>>> code ourselves.
>>
>> Speaking of red herrings. Why are we adding all this crap?
>>
>> This is a legacy filesystem! We shouldn't not be rewriting NLM/NSM from
>> scratch, just add minimal support for IPv6.
> 
> You and Bruce brought up a number of work items related to statd,
> including having distinct statd behavior for remotes who are clients and
> remotes who are servers.  Tom Talpey suggested we needed to send
> multiple SM_NOTIFY requests to each host, and use TCP to do it when
> possible, and you even specifically encouraged me to read his
> connectathon presentation on this.  If Asian countries are driving the
> IPv6 requirement, why wouldn't they want IDN support as well? 
> Interoperable NFS/IPv6 support requires TI-RPC.  Plus, NFS/IPv6
> practically requires multi-homed NLM/NSM support -- see Alex's RFC draft
> for details on that.
So a database is needed to accomplish all this? 

> 
> Let me also point out that old statd is already broken in a number of
> ways, and I certainly haven't heard a lot of complaints about it.  Our
> client NLM has sent "0" as our NSM state number for years, for example. 
> Thus I hardly think there is a lot of risk in making changes here.  It
> can only get better.
> 
I can agree with you here... 

>>> IPv6 is used in Asia, where they almost certainly need to use non-
>>> ASCII characters in their hostnames.  Internationalized domain names
>>> are stored in double-wide character sets.  To provide reliable support
>>> for IDNs in statd, we will have to guarantee somehow that we can store
>>> an IDN as a file name (if we want to stay with the current scheme), no
>>> matter what file system is used for /var.
>>
>> So, what's stopping us? These are POSIX filesystems. They can store any
>> filename as long as it doesn't contain '/' or '\0'.
> 
> IDNs are UTF16.  /var therefore has to support UTF16 filenames; either
> byte in a double-byte character can be '/' or '\0'.  That means the
> underlying fs implementation has to support UTF16 (FAT32 anyone?), and
> the system's locale has to be configured correctly.  If we decide not to
> depend on the file system to support UTF16 filenames, then statd has to
> be intelligent enough to figure out how to deal with converting UTF16
> hostnames before storing them as filenames.  Then, we have to teach
> matchhostname() and friends how to deal with double-byte character
> strings...
Has this been a problem in the past? How are other implementations 
dealing with this? Have they gone to use a db as well?
 
> 
> Or we just tell sqlite3 that this is a double-byte character string, and
> let it handle the collation and on-disk storage details for us.
> 
> The point is, this is yet another detail we have to either worry about
> and open code in statd, or we can simply rely on what's already provided
> in sqlite3.  No one, repeat NO ONE, is arguing that you can't implement
> these features without sqlite3.  My argument is that we quickly bury a
> whole bunch of details if we use sqlite3, and can then focus on larger
> issues.  That's the prime goal of software layering with libraries.
What kind of performance hit will there be (if any)? The nice thing
about a file is you only have to read it once in to a cache verses
doing a number of queries... or can one also cache queries?

> 
> We can open code any or all of statd.  In fact the current statd open
> codes RPC request creation in socket buffers rather than using glibc's
> RPC API, and I think we agree that is not an optimal solution.  The
> question is: should we duplicate code and bugs by open coding statd's
> RPC and data storage?  Or should we pretend to be modern software
> engineers, and use widely used and known good code that other people
> have written already to handle these details?
I'm all for using moving forward with "modern software" but, as 
a common theme with me, I'm always worried about becoming 
needlessly complicated or over engineering... which might be
the case with having statd use a db... 

steved.
