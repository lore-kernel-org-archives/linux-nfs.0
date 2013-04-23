Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:36799 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756281Ab3DWPmn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Apr 2013 11:42:43 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: Interoperable junctions on Linux
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1366728674.7239.63.camel@willson.li.ssimo.org>
Date: Tue, 23 Apr 2013 11:42:33 -0400
Cc: samba-technical@lists.samba.org,
        fedfs-utils Developers <fedfs-utils-devel@oss.oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BDD9FCE5-E573-4E01-A5D9-A8A3811895DD@oracle.com>
References: <71999CA2-F6E7-4DE1-9DC3-AED77626DE7F@oracle.com> <1366728674.7239.63.camel@willson.li.ssimo.org>
To: Simo Sorce <simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Simo-

Thanks for taking the time to read through my post.

On Apr 23, 2013, at 10:51 AM, Simo Sorce <simo@redhat.com> wrote:

> On Mon, 2013-04-22 at 16:39 -0400, Chuck Lever wrote:
>> Hi-
>> 
>> I led a discussion on Friday at the Linux Storage and Filesystem
>> Summit on how to store {DFS, FedFS} junctions in Linux filesystems.
>> I'd like to summarize the discussion, then ask a few follow-up
>> questions.  I apologize in advance for the length.
>> 
>> FedFS is to NFS as Microsoft DFS is to SMB/CIFS.  FedFS uses NFS
>> referrals to glue together a file namespace out of separate shares,
>> starting with a root share that may contain nothing but referrals.
>> For more on FedFS, start with RFC 5716.
>> 
>> The physical object that stores referral location target information
>> is called a junction.  It can contain an actual list of locations, or
>> it can contain the DN of an LDAP record where the location list is
>> maintained.
>> 
>> +  Samba uses a symlink for this purpose.  The contents of the link
>> represent the location information passed out to CIFS clients.
>> 
>> +  FedFS uses an extended attribute on a directory for this purpose.
>> The xattr contains XML which encodes location information passed out
>> to NFS clients.
>> 
>> The reasons for this difference are simply historical.
>> 
>> Linux is often used as a multi-protocol file service platform, where
>> the same physical data is presented to clients via both NFS and CIFS.
>> For this reason, we think there would be value in using the same
>> physical representation for both NFSD and Samba so that a single
>> junction object on our exported filesystems can trigger a referral for
>> both NFS and CIFS.
>> 
>> Samba has been around much longer, and DFS support is actually
>> deployed.  FedFS is newer and still experimental.  Thus we decided to
>> change FedFS to use a symlink instead of a directory.  Samba will
>> still use the regular contents of the symlink, and FedFS will store
>> its metadata in an extended attribute attached to the symlink.
>> 
>> There was a rough consensus to prefer JSON over XML in the FedFS
>> xattr, though there are still some who dislike both.  I'm open to
>> suggestion, since we're now essentially replacing the existing FedFS
>> junction format and can change it to anything we like.
> 
> Can you give an example or refernce of what is stored in this XML/JSON
> blob ? Why do you need structured data there ?

An "NFS basic junction" stores the location list in place.  Each item in a location list contains a number of pieces of data, including: a server hostname, an export pathname (which is a list of path components), and a number of integer and boolean settings that help clients sort which replica of this data they should mount.

A full explanation of this data is in RFC 5661, section 11.10.  This data is returned to an NFS client when it encounters one of these objects.  The client can redirect its requests to one of the servers and exports listed in the returned data.

A "FedFS junction" stores a reference to a location list stored in LDAP.  The LDAP server's hostname and port number and the UUID of a FedFS Fileset Name record are stored in the junction.  The Fileset Name record has children, each of which constitute a location (see above).

An explanation of this data is in an IETF draft:

  http://datatracker.ietf.org/doc/draft-ietf-nfsv4-federated-fs-protocol/

See chapter 4 for an overview of the schema used for these lists.  An NFS fileserver converts the LDAP records into an fs_locations4 or fs_locations_info4 attribute for NFS clients.  Other protocols use a different representation for communicating this list to clients.


> 
>> Today FedFS junctions can contain either a location list or an LDAP
>> DN.  One option for FedFS is to support only the LDAP DN junction
>> type, and have a (possibly local) LDAP service available to store the
>> location information.  The FedFS junction xattr would then always
>> contain an LDAP URL.  Storing complex data types (a list containing
>> pathnames, hostnames, integers, and other values) would then be up to
>> LDAP.
> 
> Having to install a whole LDAP server as a pre-requisite seem very heavy
> handed.

True.  Today, the LDAP/NSDB pieces are optional if an admin wants to support only "NFS basic junctions," for just this reason.

However there are certain benefits to allowing location lists to be managed via LDAP, rather than being specified at junction creation.  Junctions can share the same location list, for example.  A filesystem migration can update a central location list once, rather than having to find every junction that references the migrated filesystem.

In addition, storing these lists in a publicly available LDAP service means that any fileserver, anywhere, can access the lists.

If we are really wily, maybe a small single-purpose daemon can be constructed from a minimal LDAP server implementation (or from scratch), and it can listen on its own port or only for loopback requests.

> 
>> We will have to discuss a conjunction of administrative interfaces at
>> some later point.  However, we should clarify how our junction
>> management tools behave now that each junction can have metadata it
>> did not have before.
>> 
>> FedFS:
>> 
>>  nfsref add - if no symlink exists, create it (what contents should
>> it have?)
>>             - add an extended attribute
>> 
>>  nfsref remove - remove the extended attribute, leave the symlink
>>                - can we remove the symlink if its contents are
>> meaningless?
>> 
> Why should we leave a symlink ? Don't we expect to remove junctions for
> all protocols ?
>> 
>> Samba:
>> 
>>  add - if a symlink already exists, replace its contents, preserving
>> xattrs
>> 
>>  remove - if a FedFS extended attribute exists, leave the symlink
>> (what contents should it have?)
> 
> Why should we leave a symlink ? Don't we expect to remove junctions for
> all protocols ?

The difficulty I have is how we are going to conjoin the administrative tools that manage junctions.  I imagine that for some time, the tool used for managing DFS junctions will be unaware of FedFS junction content, and vice versa.

> What I do not get is why are you trying to use the same mechanism (a
> symlink) but then treat them as independent and separate entities ?
> What is the aim ?
> From your premise I thought you wanted to allow parallel functionality,
> ie a DFS created in samba would be seen as a junction for nfs and
> vice-versa, but the latter points seem to not allow that ?

FedFS junctions can list both NFS and SMB (and other types).  The SMB parts are not defined by the IETF, since SMB is a proprietary protocol controlled by Microsoft.

One way to have DFS and FedFS information in the same filesystem object is to have one object that can contain both.  The tools then have to be designed not to step on each other.  Eventually we figure out how to make this seamless.

I think you are suggesting we ignore this problem for now, and just have the tools pretend the other protocol does not exist, while still allowing the possibility of storing both types of metadata in the same filesystem object.  That may be an easy way to get started.

> 
> 
>> The FedFS extended attribute is called "trusted.junction.nfs".  Should
>> we rename it?
> 
> Shouldn't it be namespaced and use something like trusted.nfs.junction ?

That is probably a matter of taste.  I'm not especially attached to the current form.  But originally we had the junction information split into several attributes in the "trusted.junction" namespace.

> Also why a xattr in the trusted namespace ? What are the security
> considerations that warrants a trusted attribute rather than a normal
> one ? (Links to RFCs or other docs are just fine)

This is another historical design decision.  If there is consensus that we don't need to protect junction metadata from unintended or malicious local changes, then we can put these in another namespace.  However, without strong security here, redirecting network clients to another server and export can be hijacked, sending remote users to who knows where.  Is it enough simply to insist that junctions be owned by root?

> 
>> Note that CAP_SYS_ADMIN capabilities are required to access the xattr.
>> Will that be a problem for Samba administration tools?
>> 
> It should not be a problem for Samba, as we can retain capabilities if
> needed, and we already handle data in xattrs (not for DFS symlinks).

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




