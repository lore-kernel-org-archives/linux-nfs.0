From: "Chakravarthi P" <pchakravarthi@novell.com>
Subject: [NFS HOW To] Update please
Date: Sun, 04 Feb 2007 23:41:13 -0700
Message-ID: <45C71DB6.2C84.006B.0@novell.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=__PartA3872D99.2__="
To: <CSmithere@gmail.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDxVm-0005fN-To
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 22:39:35 -0800
Received: from lucius.provo.novell.com ([137.65.248.127])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HDxVo-0000Ta-4p
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 22:39:36 -0800
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

--=__PartA3872D99.2__=
Content-Type: multipart/alternative; boundary="=__PartA3872D99.3__="

--=__PartA3872D99.3__=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

hi cms and all=20

   this how-to addition which was posted here sometime last July.=20
   is  re-posted here for convenience.=20
   can any of the NFS HOW to maintainers respond to this as=20
   the NFS HOW To has been out of date (with respect to nfsv4)=20
   for quite some time now :-)=20

thanx=20
chax.=20

--=__PartA3872D99.3__=
Content-Type: text/html; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

<html>
  <head>
    <style type=3D"text/css">
      <!--
        body { margin-top: 4px; margin-bottom: 1px; font-variant: normal; =
margin-left: 4px; margin-right: 4px; line-height: normal }
        p { margin-top: 0; margin-bottom: 0 }
      -->
    </style>
   =20
  </head>
  <body>
    <p style=3D"margin-bottom: 0; margin-top: 0">
      <font face=3D"Dialog" size=3D"2">hi cms and all</font>    </p>
<br>     =20
    <p style=3D"margin-bottom: 0; margin-top: 0">
      <font face=3D"Dialog" size=3D"2">&nbsp;&nbsp;&nbsp;this how-to =
addition which was posted here sometime last July.</font>    </p>
    <p style=3D"margin-bottom: 0; margin-top: 0">
      <font face=3D"Dialog" size=3D"2">&nbsp;&nbsp;&nbsp;is&nbsp;&nbsp;re-p=
osted here for convenience. </font>    </p>
    <p style=3D"margin-bottom: 0; margin-top: 0">
      <font face=3D"Dialog" size=3D"2">&nbsp;&nbsp;&nbsp;can any of the =
NFS HOW to maintainers respond to this as </font>    </p>
    <p style=3D"margin-bottom: 0; margin-top: 0">
      <font face=3D"Dialog" size=3D"2">&nbsp;&nbsp;&nbsp;the NFS HOW To =
has been out of date &#40;with respect to nfsv4&#41;</font>    </p>
    <p style=3D"margin-bottom: 0; margin-top: 0">
      <font face=3D"Dialog" size=3D"2">&nbsp;&nbsp;&nbsp;for quite some =
time now :-&#41;</font>    </p>
<br>     =20
    <p style=3D"margin-bottom: 0; margin-top: 0">
      <font face=3D"Dialog" size=3D"2">thanx</font>    </p>
    <p style=3D"margin-bottom: 0; margin-top: 0">
      <font face=3D"Dialog" size=3D"2">chax.</font>
    </p>
  </body>
</html>

--=__PartA3872D99.3__=--

--=__PartA3872D99.2__=
Content-Type: text/plain; name="nfs_howto_add.txt"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="nfs_howto_add.txt"


3. NFSv4 SERVER AND CLIENT SET-UP
---------------------------------

The Network File System Version 4 (NFSv4) is a new distributed file =
system=20
similar to previous versions of NFS in its straightforward design, and=20
independence of transport protocols and operating systems for file access =
in a=20
heterogeneous network. Unlike earlier versions of NFS, the new protocol=20
integrates file locking, strong security, Compound RPCs (combining =
relevant=20
operations), and delegation capabilities to enhance client performance =
for=20
narrow data sharing applications on high-bandwidth networks. NFSv4=20
implementations are backward compatible with NFSv2 and NFSv3.
Note: NFSv4 ACLs and krb5p (Kerberos Privacy) are currently not supported

3.1. Quickstart
---------------

For NFSv4 server:
=20
1)  Edit /etc/exports to have an entry similar to the one below:=20

    /export  <client_ip/hostname/wildcard>(rw,fsid=3D0,sync,no_root_squash)=


    (i)  fsid=3D0 is a must.=20
    (ii) Replace "/export" with file tree that needs to be nfs-exported =
and
    the <client_ip/hostname/wildcard> with client's ip or hostname or =
*.=20
    (* means any client)

2)  Edit /etc/idmapd.conf to modify the default "Domain" to contain your
    DNS domain name.

3)  Execute the following commands to start idmapd and nfsserver
   =20
    SuSE:
    #/etc/init.d/idmapd start
    #/etc/init.d/nfsserver start

    Redhat:
    #/etc/init.d/rpcidmapd start
    #/etc/init.d/nfs start
   =20
For NFSv4 client:

1)  Edit /etc/idmapd.conf to modify the default "Domain" to contain your
    DNS domain name.

2)  Execute the following command to start idmapd.
    #/etc/init.d/idmapd start
=09
3)  Mount the exported file system using the following command:
    #mount -t nfs4 <servername>:/ <mntpath>
    Observe that only "/" is given instead of the actual exported path=20
    name.



3.2 Idmapd Configuration (common to both NFSv4 - client and server)
--------------------------------------------------------------------

idmapd.conf - configuration file for idmapd (idmapping daemon), which does
NFSV4<=3D>name mapping. Here dns domain (Domain) name has to be configured =
in=20
both client and server.

Sample Configuration file:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

[General]
Verbosity =3D 0
Pipefs-Directory =3D /var/lib/nfs/rpc_pipefs
Domain =3D mydomain.com

[Mapping]
Nobody-User =3D nobody
Nobody-Group =3D nobody

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D


3.3 Configuring NFSv4 Server
____________________________

There are three main configuration files you will need to edit to set up =
an=20
NFSv4 server:=20
/etc/exports, /etc/sysconfig/nfs and /etc/idmapd.conf.
We will describe the first two here as idmapd.conf is done in previous =
section.


3.3.1 /etc/exports
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

This file contains a list of entries; each entry indicates a volume that =
is
shared and how it is shared. The /etc/exports file format is slightly=20
different from previous versions. A sample exports entry looks like this.

/export  *(rw,fsid=3D0,no_subtree_check,sync,no_root_squash)

Note that:

i)  fsid - The value 0 has a special meaning when use with NFSv4. NFSv4 =
has a=20
    concept of a root of the overall exported filesystem. The export =
point=20
    exported with fsid=3D0 will be used as this root.
    There must be at least one entry with fsid=3D0. (this will be pseudo =
file
    system's /)

ii) The method used to mount multiple exported trees is different. NFSv4 =
uses=20
    the concept of pseudo filesystem to give a single file system view to =
the=20
    client with a pseudo-"/" as root of the filesystem tree. To illustrate,=


    Suppose we have
=20
    /path1/volume1
    /path2/volume2

    as two filesystem trees on the server that need to be exported, =
then=20
    Firstly, these need to be bound to another name under /export =
directory=20
    using mount command's bind option. This is done as :=20
	mount --bind <old dir> /export/<new dir>=20
    i.e. in our example:

    	#mount --bind /path1/volume1 /export/volume1
    	#mount --bind /path2/volume2 /export/volume2

    will bind these local filesystem trees to their local new names.=20
    Then these two exported filesystems (with their newly bound paths) =
are=20
    entered into /etc/exports with their respective independent options.
    i.e. /etc/exports would contain -

    /export/volume1 *(<options_to_be_filled>)
    /export/volume2 *(<options_to_be_filled>)

    This is to facilitate the pseudofilesystem concep of NFSv4 where in,
    the client sees just one file system exported to it inspite of=20
    multiple entries in /etc/exports.
    In above example, the client on mounting (look into section 3.4 for=20
    semantics), the client sees

                               / (pseudo root file system)
                            /      \
                        volume1   volume2
                            =20
iii)NFSv4 current linux implementation caters to serving NFSv2 and =
NFSv3=20
    clients too. The /etc/exports can contain both type of export =
entries=20
    even for the same filesystem trees being exported.

#######################################
# $$$ points (iv) and (v) are generic #=20
#######################################
 =20
iv) If both a directory and its subdirectory residing on different file =
systems
    need to be exported, then the option 'nohide' must be appropriately =
used.
    /export and  /export/subdir are on differnt file systems
    and both need to be exported to same client then

    /export         <client>(<options>)
    /export/subdir  <client>(<options>,nohide)
=20
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
    for manually editing the /etc/exports. Fully functional yast with =
other
    configuration editing (idmapd etc) is work in progress.


3.3.2 /etc/sysconfig/nfs
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=


/etc/sysconfig/nfs is another NFS server configuration file. Here the =
number
of kernel threads, NFSv4 support and GSS security (kerberos) for NFS can =
be=20
configured (kerberos set up is explained in the kerberos section of the =
Howto).



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

If the machines that are being used as client and server are just meant =
for=20
that, the daemons can be enabled during bootup as shown below.

Use insserv to do this

   SuSE:
	#insserv -d idmapd =20
	#insserv -d nfsserver
   Redhat:
        #insserv -d rpcidmapd
	#insserv -d nfs

and idmapd alone on the client.


3.4 Mounting remote exported directories from an NFSv4 client
_____________________________________________________________

One main difference between previous versions of NFS and NFSv4 is the way =
in
which mount is invoked. With regard to the pseudofilesystem concept=20
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
  SECURE_NFS has to be set to "yes" in /etc/sysconfig/nfs in both server =
and
  client.



4.2 Configuring Kerberized NFS server and client
________________________________________________

All the following configuration steps except 5.2.4 are for both NFSv4=20
client and server.


4.2.1 Configure kerberos=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Edit krb5.conf.
=20
Sample configuration file:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

[libdefaults]

default_realm =3D MYDOMAIN.COM
dns_lookup_realm =3D true
dns_lookup_kdc =3D true

[realms]
MYDOMAIN.COM =3D {
        kdc =3D kdcserver.mydomain.com
        admin_server =3D adminserver.mydomain.com
	default_domain =3D mydomain.com
      }

[domain_realm]
mydomain.com =3D MYDOMAIN.COM
.mydomain.com =3D MYDOMAIN.COM

[logging]
kdc =3D FILE:/var/log/krb5kdc.log
admin_server =3D FILE:/var/log/kadmin.log
default =3D FILE:/var/log/krb5lib.log

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Replace MYDOMAIN.COM with your REALM, kdcserver.mydomain.com with your =
KDC=20
server, adminserver.mydomain.com with your Admin server & mydomain.com =
with=20
your DNS domain name.

4.2.2 Create machine credentials
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D

This means creating a Kerberos V5 principal/instance name of the form=20
nfs/<hostname>@REALM, and either adding a key for this principal to=20
an existing /etc/krb5.keytab or creating an /etc/krb5.keytab.=20

Note: only the encryption type of des-cbc-crc is functional so far in =
the=20
kernel, so add only this type of key.=20

kadmin: addprinc -e des-cbc-crc:normal nfs/<hostname>@REALM
kadmin: ktadd -e des-cbc-crc:normal -k /etc/krb5.keytab nfs/<hostname>@REAL=
M

4.2.3 Configure /etc/gssapi_mech.conf=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

This configuration file determines which GSS-API mechanisms the gssd =
code=20
should use. Usually no need to modify this file in 32 bit machines =
because=20
the libraries are installed in /usr/lib.=20

Note:
1) In case of 64 bit machines this has to be modified to /usr/lib64. =
This=20
   is a workaround and will be fixed later.=20
2) Leaving the absolute path altogether and specifying just the library
   name might also work.=20

Sample configuration

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
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
# =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D      =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
# The MIT K5 gssapi library, use special function for initialization.
/usr/lib/libgssapi_krb5.so     mechglue_internal_krb5_init

# The SPKM3 gssapi library function.  Use the function spkm3_gss_initialize=
.
# /usr/local/gss_mechs/spkm/spkm3/libgssapi_spkm3.so    spkm3_gss_initializ=
e
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D


4.2.4 /etc/exports entries for a kerberized server
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=


Typical entries for kerberos security mode looks like these:

/export gss/krb5(rw,fsid=3D0,insecure,no_subtree_check,sync,no_root_squash)=

/export gss/krb5i(rw,fsid=3D0,insecure,no_subtree_check,sync,no_root_squash=
)

Note:=20
i)   krb5p (Privacy) is currently not supported.

ii)  option 'insecure' - The insecure option in this entry also allows =
clients=20
     with NFS implementations that don't use a reserved port for NFS. So =
it is=20
     advisable *NOT* to use this option unless you have a kerberised set =
up or=20
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

Or=20

To avoid starting manually, enable service during bootup using insserv =
as=20
mentioned in 4.2
=20

4.4 Mounting exported directories with kerberos
_______________________________________________

To mount a filesystem using krb5, provide the "-osec=3Dkrb5" option to =
mount.=20

	#mount -t <nfs4 or nfs> -osec=3D<secmode> nfsserver:/ /mntpoint=20

<secmode> can be krb5(Autentication) or krb5i (Integrity).


4.5 A known issue using NFS with kerberos
_________________________________________

Even if "no_root_squash" option is used, while exporting a filesystem at =
the=20
server, root on the client gets a "Permission denied"  error when =
creating=20
files on the mount point.

This is because there is no proper mapping between root and the GSSAuthName=
.

Note: Trying to set 777 permission is not correct as it is not secure. =
Also,
any file created on the mountpoint will have "nobody" as owner.

There is a work around for this if both NFS server and client use =
umich_ldap
methods to authenticate. If the idmapd on both server and client is =
configured=20
to use umich_ldap modules then having GSSAuthName (<nfs/hostname@realm>)=20=

parameter map to root user, on the ldap server will solve this problem.

A proper fix for this issue is being worked upon.



5. Troubleshooting
-------------------

5.1 Checklist to ensure NFSV4 is up and running=20
_______________________________________________

1. ps -ef | grep nfsd
   ps -ef | grep idmapd
   ps -ef | grep svcgssd=20
   to check   server side daemons are up and running.

2. ps -ef | grep idmapd
   ps -ef | grep gssd=20
   to check client side daemons are up and running

3. rpcinfo -p=20
   to check all registered RPC programs (nfs, portmapper, mountd) & =
versions

4. Check firewall is enabled on server/client from YAST.
   If yes, make sure the NFS related ports are not blocked.
   ($$$ Suse users :  Yast -> Security and Users -> Firewall. Make sure =
NFS=20
   service is enabled.)

5. showmount -e <server name>
   to check mount information on NFS server

6. For NFSv4, make sure that one and only one path is exported with =
fsid=3D0.=20
   Refer points i. and ii. in Section 3.3.1 for more information.
 =20
7. If users are not mapped properly check whether idmapd is running in =
both=20
   server & client and dns domain name is properly configured.

8. If you unable to mount, check for the correctness of the exports file =
entry.


5.2 Check list to ensure kerberos is working properly=20
_____________________________________________________

There are many reasons this could be failing.=20

1. Verify that rpc.gssd is running on the client and rpc.svcgssd is =
running=20
   on the server.

2. Verify that your hostnames are correct. The hostname command should =
return=20
   a fully-qualified hostname that has a correct DNS reverse-mapping =
(either=20
   through DNS or the /etc/hosts file).=20

3. Verify there is a keytab entry for nfs/<hostname>@REALM in your keytab =
file=20
   (/etc/krb5.keytab).=20

4. Verify your Kerberos configuration file has the proper mapping from the =
DNS=20
   hostname to the correct realm. The [domain_realm] section of the=20
   /etc/krb5.conf needs to have a mapping from the DNS domain to the =
correct=20
   REALM.=20
   For example, if your nfs server's hostname is 'foo.abc.org' and your =
Kerberos=20
   realm name is 'ALPHABET.ORG', then you need an entry like the following =
in=20
   /etc/krb5.conf on the nfs client machine:=20
  =20
   [domain_realm]
   .abc.org =3D ALPHABET.ORG

5. Verify whether your ticket is not expired or not on the client using =
klist. If
   it is expired renew using kinit. This must be checked when you find=20
   "I/O Error" or "Permission denied" while doing file operations.



--=__PartA3872D99.2__=
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--=__PartA3872D99.2__=
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=__PartA3872D99.2__=--
