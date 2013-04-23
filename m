Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:24006 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756735Ab3DWSLm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Apr 2013 14:11:42 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: Interoperable junctions on Linux
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1366736069.7239.93.camel@willson.li.ssimo.org>
Date: Tue, 23 Apr 2013 14:11:31 -0400
Cc: samba-technical@lists.samba.org,
        fedfs-utils Developers <fedfs-utils-devel@oss.oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D7E48414-53C9-45AA-B742-A579ABFC953A@oracle.com>
References: <71999CA2-F6E7-4DE1-9DC3-AED77626DE7F@oracle.com> <1366728674.7239.63.camel@willson.li.ssimo.org> <BDD9FCE5-E573-4E01-A5D9-A8A3811895DD@oracle.com> <1366736069.7239.93.camel@willson.li.ssimo.org>
To: Simo Sorce <simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 23, 2013, at 12:54 PM, Simo Sorce <simo@redhat.com> wrote:

> On Tue, 2013-04-23 at 11:42 -0400, Chuck Lever wrote:
>>> Can you give an example or refernce of what is stored in this XML/JSON
>>> blob ? Why do you need structured data there ?
>> 
>> An "NFS basic junction" stores the location list in place.  Each item
>> in a location list contains a number of pieces of data, including: a
>> server hostname, an export pathname (which is a list of path
>> components), and a number of integer and boolean settings that help
>> clients sort which replica of this data they should mount.
>> 
>> A full explanation of this data is in RFC 5661, section 11.10.  This
>> data is returned to an NFS client when it encounters one of these
>> objects.  The client can redirect its requests to one of the servers
>> and exports listed in the returned data.
>> 
>> A "FedFS junction" stores a reference to a location list stored in
>> LDAP.  The LDAP server's hostname and port number and the UUID of a
>> FedFS Fileset Name record are stored in the junction.  The Fileset
>> Name record has children, each of which constitute a location (see
>> above).
> 
> I do not see mention of LDAP URIs, andyou seem to speak in the singular
> when mention 'the LDAP server' does it mean you hve no way to specify a
> pool of LDAP servers for HA ?

An "NSDB name" (used in a junction) is meant to represent a pool of replicated LDAP server resources, or just one LDAP server.  Note that specifying IP addresses in FedFS Fileset Names is specifically disallowed for this reason.

A FedFS Fileset Name can indeed be represented by an LDAP URI.  See the operational examples in the FedFS NSDB draft.

> 
>> An explanation of this data is in an IETF draft:
>> 
>> 
>> http://datatracker.ietf.org/doc/draft-ietf-nfsv4-federated-fs-protocol/
> 
>> See chapter 4 for an overview of the schema used for these lists.  An
>> NFS fileserver converts the LDAP records into an fs_locations4 or
>> fs_locations_info4 attribute for NFS clients.  Other protocols use a
>> different representation for communicating this list to clients.
>> 
> To be honest the constrains in this document on the LDAP DIT, seem to
> indicate it will be possible to use this stuff primarily only with a
> dedicated LDAP server, Dictating how the rootDSE/namingContext should
> look like is a quite strong demand.
> 
> Why do you need a full namingContext for FedFS ?
> Why a subtree is not sufficient ?

The document does recommend using a dedicated LDAP service for an NSDB, but does not require it.

One or more of the namingContext records on an NSDB has a new attribute (fedfsNceDN) that points to the FedFS DIT.  So it is entirely possible to use an existing LDAP server for storing FedFS records, simply by adding that attribute to the namingContext under which the FedFS subtree resides.

The goal is to allow automated discovery of the location of the FedFS DIT using a DN advertised in the LDAP server's rootDSE.  NSDB clients thus need know only the name of the NSDB service.

By default, NSDBs that my tools set up store the FedFS DIT under the LDAP server's domain controller suffix, rather than using the special "o=fedfs" DN.  By convention the FedFS domain name matches the domain controller suffix, but operation doesn't depend on this.

It is not quite as restrictive as you think, but it is very fiddly to set up on industrial strength LDAP servers like OpenLDAP or 389-ds.


> On the security side, you recommend RPCSEC_GSS for NFS, but then TLS for
> LDAP, why not use SASL/GSSAPI for LDAP as well so you need a single set
> of credentials ?

There are two classes of tasks involving NSDBs: administrative, where an administrator is available to provide credential material; and fileserver, which is an unattended access performed simply to retrieve location lists.

The purpose of TLS is to allow fileservers to authenticate NSDBs without requiring user intervention.  A certificate chain for each NSDB is provisioned on fileservers (using the FedFS ADMIN RPC protocol).  The fileservers use them with START_TLS each time a connection is established to that NSDB.

SASL/GSSAPI can of course be used when performing administrative operations on an NSDB, and that is the plan for the Linux FedFS implementation.  As you observed, an administrator can then use the same credentials for an RPCGSS-protected FedFS ADMIN service and her NSDB.


> 
>> 
>>> 
>>>> Today FedFS junctions can contain either a location list or an LDAP
>>>> DN.  One option for FedFS is to support only the LDAP DN junction
>>>> type, and have a (possibly local) LDAP service available to store the
>>>> location information.  The FedFS junction xattr would then always
>>>> contain an LDAP URL.  Storing complex data types (a list containing
>>>> pathnames, hostnames, integers, and other values) would then be up to
>>>> LDAP.
>>> 
>>> Having to install a whole LDAP server as a pre-requisite seem very heavy
>>> handed.
>> 
>> True.  Today, the LDAP/NSDB pieces are optional if an admin wants to
>> support only "NFS basic junctions," for just this reason.
>> 
>> However there are certain benefits to allowing location lists to be
>> managed via LDAP, rather than being specified at junction creation.
>> Junctions can share the same location list, for example.  A filesystem
>> migration can update a central location list once, rather than having
>> to find every junction that references the migrated filesystem.
> 
> Understood.
> 
>> In addition, storing these lists in a publicly available LDAP service
>> means that any fileserver, anywhere, can access the lists.
>> 
>> If we are really wily, maybe a small single-purpose daemon can be
>> constructed from a minimal LDAP server implementation (or from
>> scratch), and it can listen on its own port or only for loopback
>> requests.
> 
> I think in most cases this is what will actually happen, but you do not
> need to use a special purpose built server, you can use an existing LDAP
> server simply specially configured for your needs. It will cause
> administrative overhead to handle this infrastructure though.

Don't I know it.

To simplify initial configuration, I've implemented a script that installs OpenLDAP and performs enough configuration to provide a stand-alone NSDB, with or without TLS.  I already have a number of C tools that can set up the rootDSE and add Fileset Name records on either 389-ds or OpenLDAP servers.

The idea is to allow both types of NSDB (stand-alone, and as part of an existing LDAP service), but that kind of generality adds a lot of complexity to the set up process and documentation.  Going with just one or the other makes life much easier.


> 
> [..]
> 
>>> Why should we leave a symlink ? Don't we expect to remove junctions for
>>> all protocols ?
>> 
>> The difficulty I have is how we are going to conjoin the
>> administrative tools that manage junctions.  I imagine that for some
>> time, the tool used for managing DFS junctions will be unaware of
>> FedFS junction content, and vice versa.
> 
> Yes, for some time one may end up wiping out the other.
> 
>>> What I do not get is why are you trying to use the same mechanism (a
>>> symlink) but then treat them as independent and separate entities ?
>>> What is the aim ?
>>> From your premise I thought you wanted to allow parallel functionality,
>>> ie a DFS created in samba would be seen as a junction for nfs and
>>> vice-versa, but the latter points seem to not allow that ?
>> 
>> FedFS junctions can list both NFS and SMB (and other types).  The SMB
>> parts are not defined by the IETF, since SMB is a proprietary protocol
>> controlled by Microsoft.
>> 
>> One way to have DFS and FedFS information in the same filesystem
>> object is to have one object that can contain both.  The tools then
>> have to be designed not to step on each other.  Eventually we figure
>> out how to make this seamless.
>> 
>> I think you are suggesting we ignore this problem for now, and just
>> have the tools pretend the other protocol does not exist, while still
>> allowing the possibility of storing both types of metadata in the same
>> filesystem object.  That may be an easy way to get started.
> 
> I thought this was what you were proposing actually. With my
> 'integrator' hat on I would rather quickly define common tools that can
> handle both, and have the old tools return loud warnings (were possible)
> if you try to use them.

The "old" FedFS tools in this case are available because they are one of two independent reference implementations required for the IETF standardization process.  However, I think solving the problem of integrating FedFS ADMIN with an existing DFS implementation on a multi-protocol fileserver is going to be very valuable implementation experience that can be fed back into the IETF standards process.

I'm not confident we can fit rpc.fedfsd (Linux's implementation of the FedFS RPC ADMIN service) into this model, so we may end up abandoning its use for managing FedFS junctions, leaving it only to provisioning NSDB certificates.

> In the Samba case the basic tool is 'ln', not sure we can do much about
> it :-) But we can certainly patch the RPC code that allows handling via
> SMB/RPC although I am not quite sure how to populate all the data the
> SMB world has no concept of, perhaps using 'good defaults' ...

Exactly the problem.

My thought was to define a place-holder value for both protocols that can be used by our existing tools, for now.  No xattr for symlinks created on behalf of DFS, and maybe an empty symlink for junctions created by rpc.fedfsd or the nfsref command.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




