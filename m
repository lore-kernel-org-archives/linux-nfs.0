From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: problem starting rpc.svcgssd for NFSv4
Date: Mon, 14 Mar 2005 05:36:45 -0800 (PST)
Message-ID: <20050314133645.26617.qmail@web51604.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DApkb-0003qA-Q3
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 05:36:53 -0800
Received: from web51604.mail.yahoo.com ([206.190.38.209])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1DApkY-0000A0-BS
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 05:36:53 -0800
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi , 
      I am trying to set up kerberos for NFSv4
      All the daemons other than rpc.svcgssd start.

      I have krb5kdc and kadmind running on (RHEL4)
      vcslinux1 system.

      
      file /etc/krb5.keytab has following contents:
     
nfs/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM
root/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM

      #rpc.svcgssd -v -f

      WARNING: unable to locate function 
      krb5_gss_internal_release_oid in krb5
      mechanism library: there will be problems
      if multiple mechanisms are used!
      ERROR: GSS-API: error in gss_acquire_cred(): 
      Miscellaneous failure - Unsupported key table
      format version number unable to obtain root 
     (machine) credentials
      do you have a keytab entry for   
      nfs/<your.host>@<YOUR.REALM> in
/etc/krb5.keytab?


thanks,
 --kiran



		
__________________________________ 
Do you Yahoo!? 
Yahoo! Small Business - Try our new resources site!
http://smallbusiness.yahoo.com/resources/ 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
