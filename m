From: Vladimir Vuksan <croatia@firstlinux.net>
Subject: NFS over TCP on a Linux server
Date: Tue, 21 May 2002 12:20:57 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020521192057.47EAD3ECD@sitemail.everyone.net>
Reply-To: croatia@firstlinux.net
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

I am trying to set up NFS over TCP on a Linux server. However I cannot figure out how to register NFS over TCP with the portmapper ie. Doing pmap_dump yields

    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs

I tried adding

    100003    3   tcp   2049  nfs

and doing

cat p.dump | pmap_set

but that doesn't seem to work.

How does one register it ?

Thanks,
Vladimir

_____________________________________________________________
Want a new web-based email account ? ---> http://www.firstlinux.net

_____________________________________________________________
Promote your group and strengthen ties to your members with email@yourgroup.org by Everyone.net  http://www.everyone.net/?btn=tag

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
