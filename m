From: "Chakravarthi P" <pchakravarthi@novell.com>
Subject: Re: Update to the NFS Howto
Date: Tue, 18 Jul 2006 08:06:43 -0600
Message-ID: <44BD3638.2C84.006B.0@novell.com>
References: <4489840C0200006B0000515A@lucius.provo.novell.com>
	<2b585fc90606120403w755dfe76gb185ca135eed3732@mail.gmail.com>
	<2b585fc90606120633n746a8a6ex9d6105c23a872bc3@mail.gmail.com>
	<44B7C69E.2C84.006B.0@novell.com>
	<4d569c330607140703r3a81f30ds596235774e3af61b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=__Part99BC6CE3.2__="
Cc: nfs@lists.sourceforge.net,
	Christopher Smith <csmithere@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G2qCX-0007vG-1Y
	for nfs@lists.sourceforge.net; Tue, 18 Jul 2006 07:05:29 -0700
Received: from lucius.provo.novell.com ([137.65.81.172])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G2qCW-0002HG-I4
	for nfs@lists.sourceforge.net; Tue, 18 Jul 2006 07:05:29 -0700
To: "Kevin Coffman" <kwc@citi.umich.edu>
In-Reply-To: <4d569c330607140703r3a81f30ds596235774e3af61b@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a MIME message. If you are reading this text, you may want to 
consider changing to a mail reader or gateway that understands how to 
properly handle MIME multipart messages.

--=__Part99BC6CE3.2__=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

thanx Kevin for those comments.
the modified how to portions are 
attached.

Chris, Kevin and others please getback
if you find any issues.

Chris, is this the way you want the chapters
to be in the HOWTO you are maintaining?

thanx
chax.

>>> On Fri, Jul 14, 2006 at  7:33 PM, in message
<4d569c330607140703r3a81f30ds596235774e3af61b@mail.gmail.com>, "Kevin
Coffman"
<kwc@citi.umich.edu> wrote: 
> Some quick comments:
> 
> The following are more differences between suse and redhat:
> 
> suse                                 redhat
> ---------------------------             
------------------------------
> /etc/init.d/nfsserver             /etc/init.d/nfs
> /etc/init.d/gssd                   /etc/init.d/rpcgssd
> /etc/init.d/svcgssd              /etc/init.d/rpcsvcgssd
> /etc/init.d/idmapd               /etc/init.d/rpcidmapd
> 
> In /etc/sysconfig/nfs:
> 
> NFS_SECURITY_GSS       SECURE_NFS
> 
> Leaving off the path entirely in the /etc/gssapi_mech.conf file may
be
> a work- around for 32/64 compatibility:
> 
> # library                               initialization function
> # =================      ==========================
> # The MIT K5 gssapi library, use special function for
initialization.
> libgssapi_krb5.so                 mechglue_internal_krb5_init
> 
> 
> The other idmapd mapping method is "umich_ldap", not "ldap_umich".
> 
> Thanks,
> K.C.
> 
> 
> On 7/14/06, Chakravarthi P <pchakravarthi@novell.com> wrote:
>>
>> Cms and all
>>
>>   there are 3 sections in the attached txt file for addressing
'howto'
>> -
>>   specific to nfsv4 and kerberos.
>>   i have marked a $$$ whenever something mentioned is suse specfic
>>   or if it is not specific to NFSv4 but NFS in general.
>>   please get back with your comments.
>>
>> regards,
>> chax.
>>
>>
>>
>>
>> >>> On Mon, Jun 12, 2006 at  7:03 PM, in message
>> <2b585fc90606120633n746a8a6ex9d6105c23a872bc3@mail.gmail.com>,
>> "Christopher
>> Smith" <csmithere@gmail.com> wrote:
>> > Chax--
>> >
>> > Thank you very much for what you have submitted.  A few comments:
>> >
>> > a) Some of the information tin the README is general to Linux,
and
>> > applies to all 2.6 implementations.
>> > b) Some of the information here applies to SuSE specifically.
>> > c) The Kerberos configuration section applies to both NFS Version
3
>> as
>> > well as NFS Version 4.
>> >
>> > What I would suggest is we do the following:
>> >
>> > * Break out the portions that apply specifically to NFS Version 4
>> into
>> > sections 3 and 4 of the HOWTO for server and client
configuration.
>> > * Break out the Kerberos documentation you've generated into a
>> > subsection of the Security portion of the HOWTO, since it applies
to
>> > all NFS versions.
>> > * Add notation where specific SuSE related configuration is
>> required.
>> >
>> > Either you or I can do this.  Its up to you.
>> >
>> > Is this acceptable?
>> >
>> > Best,
>> > CMS
>> >
>> >
>>
>>
>>
>>
>>
>>
>>
-------------------------------------------------------------------------
>> Using Tomcat but need to do more? Need to support web services,
security?
>> Get stuff done quickly with pre- integrated technology to make your
job easier
>> Download IBM WebSphere Application Server v.1.0.1 based on Apache
Geronimo
>> http://sel.as-
us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
>>
>>
>> _______________________________________________
>> NFS maillist  -   NFS@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/nfs
>>
>>
>>
>>



--=__Part99BC6CE3.2__=
Content-Type: text/plain; name="nfs_howto_add.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="nfs_howto_add.txt"


3. NFSv4 SERVER AND CLIENT SET-UP
---------------------------------

The Network File System Version 4 (NFSv4) is a new distributed file system 
similar to previous versions of NFS in its straightforward design, and 
independence of transport protocols and operating systems for file access in a 
heterogeneous network. Unlike earlier versions of NFS, the new protocol 
integrates file locking, strong security, Compound RPCs (combining relevant 
operations), and delegation capabilities to enhance client performance for 
narrow data sharing applications on high-bandwidth networks. NFSv4 
implementations are backward compatible with NFSv2 and NFSv3.
Note: NFSv4 ACLs and krb5p (Kerberos Privacy) are currently not supported

3.1. Quickstart
---------------

For NFSv4 server:
 
1)  Edit /etc/exports to have an entry similar to the one below: 

    /export  <client_ip/hostname/wildcard>(rw,fsid=0,sync,no_root_squash)

    (i)  fsid=0 is a must. 
    (ii) Replace "/export" with file tree that needs to be nfs-exported and
    the <client_ip/hostname/wildcard> with client's ip or hostname or *. 
    (* means any client)

2)  Edit /etc/idmapd.conf to modify the default "Domain" to contain your
    DNS domain name.

3)  Execute the following commands to start idmapd and nfsserver
    
    SuSE:
    #/etc/init.d/idmapd start
    #/etc/init.d/nfsserver start

    Redhat:
    #/etc/init.d/rpcidmapd start
    #/etc/init.d/nfs start
    
For NFSv4 client:

1)  Edit /etc/idmapd.conf to modify the default "Domain" to contain your
    DNS domain name.

2)  Execute the following command to start idmapd.
    #/etc/init.d/idmapd start
	
3)  Mount the exported file system using the following command:
    #mount -t nfs4 <servername>:/ <mntpath>
    Observe that only "/" is given instead of the actual exported path 
    name.



3.2 Idmapd Configuration (common to both NFSv4 - client and server)
--------------------------------------------------------------------

idmapd.conf - configuration file for idmapd (idmapping daemon), which does
NFSV4<=>name mapping. Here dns domain (Domain) name has to be configured in 
both client and server.

Sample Configuration file:

==========================================================================

[General]
Verbosity = 0
Pipefs-Directory = /var/lib/nfs/rpc_pipefs
Domain = mydomain.com

[Mapping]
Nobody-User = nobody
Nobody-Group = nobody

==========================================================================


3.3 Configuring NFSv4 Server
____________________________

There are three main configuration files you will need to edit to set up an 
NFSv4 server: 
/etc/exports, /etc/sysconfig/nfs and /etc/idmapd.conf.
We will describe the first two here as idmapd.conf is done in previous section.


3.3.1 /etc/exports
==================

This file contains a list of entries; each entry indicates a volume that is
shared and how it is shared. The /etc/exports file format is slightly 
different from previous versions. A sample exports entry looks like this.

/export  *(rw,fsid=0,no_subtree_check,sync,no_root_squash)

Note that:

i)  fsid - The value 0 has a special meaning when use with NFSv4. NFSv4 has a 
    concept of a root of the overall exported filesystem. The export point 
    exported with fsid=0 will be used as this root.
    There must be at least one entry with fsid=0. (this will be pseudo file
    system's /)

ii) The method used to mount multiple exported trees is different. NFSv4 uses 
    the concept of pseudo filesystem to give a single file system view to the 
    client with a pseudo-"/" as root of the filesystem tree. To illustrate,

    Suppose we have
 
    /path1/volume1
    /path2/volume2

    as two filesystem trees on the server that need to be exported, then 
    Firstly, these need to be bound to another name under /export directory 
    using mount command's bind option. This is done as : 
	mount --bind <old dir> /export/<new dir> 
    i.e. in our example:

    	#mount --bind /path1/volume1 /export/volume1
    	#mount --bind /path2/volume2 /export/volume2

    will bind these local filesystem trees to their local new names. 
    Then these two exported filesystems (with their newly bound paths) are 
    entered into /etc/exports with their respective independent options.
    i.e. /etc/exports would contain -

    /export/volume1 *(<options_to_be_filled>)
    /export/volume2 *(<options_to_be_filled>)

    This is to facilitate the pseudofilesystem concep of NFSv4 where in,
    the client sees just one file system exported to it inspite of 
    multiple entries in /etc/exports.
    In above example, the client on mounting (look into section 3.4 for 
    semantics), the client sees

                               / (pseudo root file system)
                            /      \
                        volume1   volume2
                             
iii)NFSv4 current linux implementation caters to serving NFSv2 and NFSv3 
    clients too. The /etc/exports can contain both type of export entries 
    even for the same filesystem trees being exported.

#######################################
# $$$ points (iv) and (v) are generic # 
#######################################
  
iv) If both a directory and its subdirectory residing on different file systems
    need to be exported, then the option 'nohide' must be appropriately used.
    /export and  /export/subdir are on differnt file systems
    and both need to be exported to same client then

    /export         <client>(<options>)
    /export/subdir  <client>(<options>,nohide)
 
    must be done so that the client can see the contents of subdir too.
    Though this is not specific to NFSv4, it is seen as a common use case
    scenario and is included here.
    'man exports' has detailed information regarding the options.

v)  In case of different kind of exports for the same exported path the
    syntax that must be followed is either of the following
    /export  host1(<options>) host2(<options>)
    (or)
    /export  host1(<options>)
    /export  host2(<options>)


################################
# $$$ Suse specific point (vi) #
################################

vi) Currently Yast2's nfs-server module can only be used as a subsitute
    for manually editing the /etc/exports. Fully functional yast with other
    configuration editing (idmapd etc) is work in progress.


3.3.2 /etc/sysconfig/nfs
=========================

/etc/sysconfig/nfs is another NFS server configuration file. Here the number
of kernel threads, NFSv4 support and GSS security (kerberos) for NFS can be 
configured (kerberos set up is explained in the kerberos section of the Howto).



3.4 Starting services on server and client
__________________________________________

We need to start idmapd and nfsserver on the NFSv4 server.

   SuSE:
	#/etc/init.d/idmapd start
	#/etc/init.d/nfsserver start

   Redhat:
	#/etc/init.d/rpcidmapd start
	#/etc/init.d/nfs start


and start idmapd alone on the client.

If the machines that are being used as client and server are just meant for 
that, the daemons can be enabled during bootup as shown below.

Use insserv to do this

   SuSE:
	#insserv -d idmapd  
	#insserv -d nfsserver
   Redhat:
        #insserv -d rpcidmapd
	#insserv -d nfs

and idmapd alone on the client.


3.4 Mounting remote exported directories from an NFSv4 client
_____________________________________________________________

One main difference between previous versions of NFS and NFSv4 is the way in
which mount is invoked. With regard to the pseudofilesystem concept 
sketched above, mount is done as follows:

	#mount -t nfs4 <servername>:/  <mntpath>

	Observe that only '/' is given after the servername.



4. NFS WITH KERBEROS
--------------------

Kerberos support for NFSv3 is possible if the server has the laters
NFS code. It is just that NFSv4 server caters to v3 clients too. So,
kerberos wouldn't work with old code.

4.1 Prerequisites
_________________

o Key Distribution Center (KDC) must already be set up on the network.
o krb5-1.4.x must be installed on both NFS server and NFS client.
o krb5-client-1.4.x must be installed on both NFS server and NFS client.
o NFS server, client and the KDC server must have their time synchronized.
o SuSE:
  NFS_SECURITY_GSS has to be set to "yes" in /etc/sysconfig/nfs in both
  server and client.
  Redhat:
  SECURE_NFS has to be set to "yes" in /etc/sysconfig/nfs in both server and
  client.



4.2 Configuring Kerberized NFS server and client
________________________________________________

All the following configuration steps except 5.2.4 are for both NFSv4 
client and server.


4.2.1 Configure kerberos 
========================

Edit krb5.conf.
 
Sample configuration file:

==========================================================================

[libdefaults]

default_realm = MYDOMAIN.COM
dns_lookup_realm = true
dns_lookup_kdc = true

[realms]
MYDOMAIN.COM = {
        kdc = kdcserver.mydomain.com
        admin_server = adminserver.mydomain.com
	default_domain = mydomain.com
      }

[domain_realm]
mydomain.com = MYDOMAIN.COM
.mydomain.com = MYDOMAIN.COM

[logging]
kdc = FILE:/var/log/krb5kdc.log
admin_server = FILE:/var/log/kadmin.log
default = FILE:/var/log/krb5lib.log

==========================================================================

Replace MYDOMAIN.COM with your REALM, kdcserver.mydomain.com with your KDC 
server, adminserver.mydomain.com with your Admin server & mydomain.com with 
your DNS domain name.

4.2.2 Create machine credentials
================================

This means creating a Kerberos V5 principal/instance name of the form 
nfs/<hostname>@REALM, and either adding a key for this principal to 
an existing /etc/krb5.keytab or creating an /etc/krb5.keytab. 

Note: only the encryption type of des-cbc-crc is functional so far in the 
kernel, so add only this type of key. 

kadmin: addprinc -e des-cbc-crc:normal nfs/<hostname>@REALM
kadmin: ktadd -e des-cbc-crc:normal -k /etc/krb5.keytab nfs/<hostname>@REALM

4.2.3 Configure /etc/gssapi_mech.conf 
=====================================

This configuration file determines which GSS-API mechanisms the gssd code 
should use. Usually no need to modify this file in 32 bit machines because 
the libraries are installed in /usr/lib. 

Note:
1) In case of 64 bit machines this has to be modified to /usr/lib64. This 
   is a workaround and will be fixed later. 
2) Leaving the absolute path altogether and specifying just the library
   name might also work. 

Sample configuration

==========================================================================
# GSSAPI Mechanism Definitions
#
# This configuration file determines which GSS-API mechanisms
# the gssd code should use
#
# NOTE:
# The initialization function "mechglue_internal_krb5_init"
# is used for the MIT krb5 gssapi mechanism.  This special
# function name indicates that an internal function should
# be used to determine the entry points for the MIT gssapi
# mechanism functions.
#
# library                               initialization function
# ================================      ==========================
# The MIT K5 gssapi library, use special function for initialization.
/usr/lib/libgssapi_krb5.so     mechglue_internal_krb5_init

# The SPKM3 gssapi library function.  Use the function spkm3_gss_initialize.
# /usr/local/gss_mechs/spkm/spkm3/libgssapi_spkm3.so    spkm3_gss_initialize
==========================================================================


4.2.4 /etc/exports entries for a kerberized server
==================================================

Typical entries for kerberos security mode looks like these:

/export gss/krb5(rw,fsid=0,insecure,no_subtree_check,sync,no_root_squash)
/export gss/krb5i(rw,fsid=0,insecure,no_subtree_check,sync,no_root_squash)

Note: 
i)   krb5p (Privacy) is currently not supported.

ii)  option 'insecure' - The insecure option in this entry also allows clients 
     with NFS implementations that don't use a reserved port for NFS. So it is 
     advisable *NOT* to use this option unless you have a kerberised set up or 
     you know what you are doing.


4.3 Starting the services on server and client
______________________________________________

On NFSv4 server, svcgssd needs to be started too. So,

	#/etc/init.d/idmapd start
	#/etc/init.d/svcgssd start
	#/etc/init.d/nfsserver start

On NFSv4 client, gssd needs to be started too. So,

	#/etc/init.d/idmapd start
	#/etc/init.d/gssd start

Or 

To avoid starting manually, enable service during bootup using insserv as 
mentioned in 4.2
 

4.4 Mounting exported directories with kerberos
_______________________________________________

To mount a filesystem using krb5, provide the "-osec=krb5" option to mount. 

	#mount -t <nfs4 or nfs> -osec=<secmode> nfsserver:/ /mntpoint 

<secmode> can be krb5(Autentication) or krb5i (Integrity).


4.5 A known issue using NFS with kerberos
_________________________________________

Even if "no_root_squash" option is used, while exporting a filesystem at the 
server, root on the client gets a "Permission denied"  error when creating 
files on the mount point.

This is because there is no proper mapping between root and the GSSAuthName.

Note: Trying to set 777 permission is not correct as it is not secure. Also,
any file created on the mountpoint will have "nobody" as owner.

There is a work around for this if both NFS server and client use umich_ldap
methods to authenticate. If the idmapd on both server and client is configured 
to use umich_ldap modules then having GSSAuthName (<nfs/hostname@realm>) 
parameter map to root user, on the ldap server will solve this problem.

A proper fix for this issue is being worked upon.



5. Troubleshooting
-------------------

5.1 Checklist to ensure NFSV4 is up and running 
_______________________________________________

1. ps -ef | grep nfsd
   ps -ef | grep idmapd
   ps -ef | grep svcgssd 
   to check   server side daemons are up and running.

2. ps -ef | grep idmapd
   ps -ef | grep gssd 
   to check client side daemons are up and running

3. rpcinfo -p 
   to check all registered RPC programs (nfs, portmapper, mountd) & versions

4. Check firewall is enabled on server/client from YAST.
   If yes, make sure the NFS related ports are not blocked.
   ($$$ Suse users :  Yast -> Security and Users -> Firewall. Make sure NFS 
   service is enabled.)

5. showmount -e <server name>
   to check mount information on NFS server

6. For NFSv4, make sure that one and only one path is exported with fsid=0. 
   Refer points i. and ii. in Section 3.3.1 for more information.
  
7. If users are not mapped properly check whether idmapd is running in both 
   server & client and dns domain name is properly configured.

8. If you unable to mount, check for the correctness of the exports file entry.


5.2 Check list to ensure kerberos is working properly 
_____________________________________________________

There are many reasons this could be failing. 

1. Verify that rpc.gssd is running on the client and rpc.svcgssd is running 
   on the server.

2. Verify that your hostnames are correct. The hostname command should return 
   a fully-qualified hostname that has a correct DNS reverse-mapping (either 
   through DNS or the /etc/hosts file). 

3. Verify there is a keytab entry for nfs/<hostname>@REALM in your keytab file 
   (/etc/krb5.keytab). 

4. Verify your Kerberos configuration file has the proper mapping from the DNS 
   hostname to the correct realm. The [domain_realm] section of the 
   /etc/krb5.conf needs to have a mapping from the DNS domain to the correct 
   REALM. 
   For example, if your nfs server's hostname is 'foo.abc.org' and your Kerberos 
   realm name is 'ALPHABET.ORG', then you need an entry like the following in 
   /etc/krb5.conf on the nfs client machine: 
   
   [domain_realm]
   .abc.org = ALPHABET.ORG

5. Verify whether your ticket is not expired or not on the client using klist. If
   it is expired renew using kinit. This must be checked when you find 
   "I/O Error" or "Permission denied" while doing file operations.


--=__Part99BC6CE3.2__=
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--=__Part99BC6CE3.2__=
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=__Part99BC6CE3.2__=--
