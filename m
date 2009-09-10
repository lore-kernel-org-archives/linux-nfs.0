Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:22331 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbZIJPBr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Sep 2009 11:01:47 -0400
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Jeff Layton <jlayton@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Message-Id: <55A1A361-515F-4E4D-9298-CA13772E3C94@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <4AA83715.80205@RedHat.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st part)
Date: Thu, 10 Sep 2009 11:01:10 -0400
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net> <20090805144540.12866.22084.stgit@matisse.1015granger.net> <20090805174811.GB9944@fieldses.org> <DBAD3130-0633-414A-914B-CC2F15ABB219@oracle.com> <20090805181545.GF9944@fieldses.org> <7330021D-C95A-463D-8D18-29453EF185BC@oracle.com> <1249507356.5428.11.camel@heimdal.trondhjem.org> <D503383F-3D52-4F93-B850-AFE84316435C@oracle.com> <1249515004.5428.34.camel@heimdal.trondhjem.org> <20090909142945.755da393@tlielax.poochiereds.net> <1252521599.8722.53.camel@heimdal.trondhjem.org> <20B7C2F0-E566-4292-91E9-41A3FA6C9D4C@oracle.com> <1252525327.8722.81.camel@heimdal.trondhjem.org> <D2B488FA-2630-4355-8E3B-FE1243E4C3AE@oracle.com> <4AA83715.80205@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sep 9, 2009, at 7:15 PM, Steve Dickson wrote:
> On 09/09/2009 06:18 PM, Chuck Lever wrote:
>> On Sep 9, 2009, at 3:42 PM, Trond Myklebust wrote:
>>> On Wed, 2009-09-09 at 15:17 -0400, Chuck Lever wrote:
>>>> On Sep 9, 2009, at 2:39 PM, Trond Myklebust wrote:
>>>> The old statd still exists in nfs-utils.  The new statd is an  
>>>> entirely
>>>> separate component.  Distributions can continue to use the old  
>>>> statd
>>>> as long as they want.  This is a red herring.
>>>
>>> Bullshit. If they are adding IPv6 support, then they will have to
>>> upgrade at some point.
>>
>> I don't see a problem with a distribution upgrade using old statd  
>> and a
>> fresh install using new statd.  You have to install a lot of new
>> components to get NFS/IPv6 support.
> What new components that are not already being installed??

You need a kernel that can do NFS/IPv6, you need to install rpcbind  
and libtirpc, you need the new mount command, you need all the user  
space network pieces to manage IPv6, you need to consider firewall and  
address distribution on your local network, and you need statd and  
mountd/exportfs to get NFS/IPv6 support.

Configuring a system for IPv6 support can also be nontrivial, and not  
something people will do on a whim.

I didn't mean to imply that some of these components are not already  
installed.  My point is that the required changes for NFS/IPv6 are  
wide spread, and that most people would opt for installing a new OS on  
their systems to get these features, rather than upgrade all of these  
items piecemeal.

>> And you have never clearly answered why it wouldn't be enough to  
>> add a
>> little code to convert the current on-disk format to sqlite3 when
>> upgrading to the new statd, if upgradability is truly an important
>> requirement.  Possibly this is because it eliminates the only real
>> technical objection you have to using sqlite3 here.
> The issue I would have with using sqlite3 is it would add yet another
> requirement on nfs-utils... I really don't know how big sqlite3 and/or
> sqlite3-devel (possibly needed for builds) packages are but it just
> one more thing will be need for nfs-utils to function...

sqlite3.org provides a single source file version of sqlite3 that is  
licensed and designed explicitly for folks to include in their own  
code, without the need for linking a library.  You can even disable a  
number of build time options to reduce object size.

This means that the libsqlite3 and libsqlite3-devel packages would not  
be required on either the build system or the end system, and it  
eliminates the issue of whether libsqlite3.so can be moved to /lib.

>>>>> Simplicity is another reason. WTF do we need a full SQL  
>>>>> database, when
>>>>> all we want to do is store 2 pieces of data (a hostname and a  
>>>>> cookie)?
>>>>> It isn't as if this has been a major problem for us previously.
>>>>
>>>> Because we are not storing just a hostname and a cookie.  We are
>>>> storing several different data items for each host, and we need to
>>>> search over the records, and provide uniqueness constraints, and
>>>> handle data conversion (for binary data like the cookie, for string
>>>> data like the hostname, and for integers, like the prog/vers/proc
>>>> tuple).  We need to store them durably on persistent storage to  
>>>> have
>>>> some protection against crashes.  These are all things that an
>>>> embedded database can do well, and that we therefore don't have to
>>>> code ourselves.
>>>
>>> Speaking of red herrings. Why are we adding all this crap?
>>>
>>> This is a legacy filesystem! We shouldn't not be rewriting NLM/NSM  
>>> from
>>> scratch, just add minimal support for IPv6.
>>
>> You and Bruce brought up a number of work items related to statd,
>> including having distinct statd behavior for remotes who are  
>> clients and
>> remotes who are servers.  Tom Talpey suggested we needed to send
>> multiple SM_NOTIFY requests to each host, and use TCP to do it when
>> possible, and you even specifically encouraged me to read his
>> connectathon presentation on this.  If Asian countries are driving  
>> the
>> IPv6 requirement, why wouldn't they want IDN support as well?
>> Interoperable NFS/IPv6 support requires TI-RPC.  Plus, NFS/IPv6
>> practically requires multi-homed NLM/NSM support -- see Alex's RFC  
>> draft
>> for details on that.
> So a database is needed to accomplish all this?

No, a database is not specifically required.

However, libsqlite3 is a library that contains all of the elements --  
durable on-disk storage, proper data conversion for binary blobs,  
single- and double-width character strings, integers, the ability to  
constrain record uniqueness, the ability to add new data items easily  
to each record, and a facility for collating and searching the host  
records.

sqlite3 is an embedded database, meaning the implementation is  
purposely smaller than a full SQL database, and is designed explicitly  
to have zero database administration requirements.  sqlite3 is  
designed for managing data for long-running network daemons, and it is  
widely used for that purpose.

If there is some other pre-existing code that can do this, I'm open to  
considering it.

>> Let me also point out that old statd is already broken in a number of
>> ways, and I certainly haven't heard a lot of complaints about it.   
>> Our
>> client NLM has sent "0" as our NSM state number for years, for  
>> example.
>> Thus I hardly think there is a lot of risk in making changes here.   
>> It
>> can only get better.
>>
> I can agree with you here...
>
>>>> IPv6 is used in Asia, where they almost certainly need to use non-
>>>> ASCII characters in their hostnames.  Internationalized domain  
>>>> names
>>>> are stored in double-wide character sets.  To provide reliable  
>>>> support
>>>> for IDNs in statd, we will have to guarantee somehow that we can  
>>>> store
>>>> an IDN as a file name (if we want to stay with the current  
>>>> scheme), no
>>>> matter what file system is used for /var.
>>>
>>> So, what's stopping us? These are POSIX filesystems. They can  
>>> store any
>>> filename as long as it doesn't contain '/' or '\0'.
>>
>> IDNs are UTF16.  /var therefore has to support UTF16 filenames;  
>> either
>> byte in a double-byte character can be '/' or '\0'.  That means the
>> underlying fs implementation has to support UTF16 (FAT32 anyone?),  
>> and
>> the system's locale has to be configured correctly.  If we decide  
>> not to
>> depend on the file system to support UTF16 filenames, then statd  
>> has to
>> be intelligent enough to figure out how to deal with converting UTF16
>> hostnames before storing them as filenames.  Then, we have to teach
>> matchhostname() and friends how to deal with double-byte character
>> strings...
> Has this been a problem in the past? How are other implementations
> dealing with this? Have they gone to use a db as well?

No, IDNs are recent, but it is reasonable to think that  
internationalized domain names is a feature that would appeal to the  
same folks who are driving the IPv6 requirement.  This is not a hard  
requirement, but it is one reason why statd's current on-disk format  
is not adequate.

Yes, I understand that there are some statd implementations that use a  
database rather than flat files.  statd is nothing if not exactly a  
mechanism for storing structured data across system crashes.  That's  
exactly what databases are for.

>> Or we just tell sqlite3 that this is a double-byte character  
>> string, and
>> let it handle the collation and on-disk storage details for us.
>>
>> The point is, this is yet another detail we have to either worry  
>> about
>> and open code in statd, or we can simply rely on what's already  
>> provided
>> in sqlite3.  No one, repeat NO ONE, is arguing that you can't  
>> implement
>> these features without sqlite3.  My argument is that we quickly  
>> bury a
>> whole bunch of details if we use sqlite3, and can then focus on  
>> larger
>> issues.  That's the prime goal of software layering with libraries.
> What kind of performance hit will there be (if any)? The nice thing
> about a file is you only have to read it once in to a cache verses
> doing a number of queries... or can one also cache queries?

sqlite3's performance for the statd application would actually be  
better than what we have today.

Naturally the database is cached in memory, making queries as fast as  
memory reads.  The better performance comes with record insertion and  
deletion.  Today statd does a file create and then an O_SYNC write to  
that file.  This requires synchronous metadata updates to the file  
system to create the new file and create a new directory entry for  
it.  If the directory becomes large, creating a new directory entry  
becomes even slower.  Likewise for record deletion, multiple  
synchronous metadata updates are required to remove the directory  
entry and the file containing the host record.

With sqlite3 (or any database style solution) record insertion and  
deletion can usually be handled with a single O_SYNC write to the  
database file.

You could argue that using sqlite3 means more CPU and memory  
consumption.  Perhaps, but that's a less onerous resource requirement  
than synchronous disk activity, in my view.

>> We can open code any or all of statd.  In fact the current statd open
>> codes RPC request creation in socket buffers rather than using  
>> glibc's
>> RPC API, and I think we agree that is not an optimal solution.  The
>> question is: should we duplicate code and bugs by open coding statd's
>> RPC and data storage?  Or should we pretend to be modern software
>> engineers, and use widely used and known good code that other people
>> have written already to handle these details?
> I'm all for using moving forward with "modern software" but, as
> a common theme with me, I'm always worried about becoming
> needlessly complicated or over engineering... which might be
> the case with having statd use a db...

Consider what would happen if we open coded all of the details of on- 
disk storage and record searching into statd itself.  I think  
something like sqlite3 is a better and less complex solution than open  
coding because all these details are moved out of statd into a pre- 
existing library, thus making statd itself architecturally simpler,  
and therefore easier to understand and maintain.

The one weakness here is the dependence on SQL.  That makes the statd  
code uglier and more complex than I would like, and is something I  
want to address.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



