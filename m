From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: [SOLVED] RE: debugging failed lock recovery
Date: Tue, 1 Feb 2005 15:42:13 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0502011532260.8434@harp.ngdc.noaa.gov>
References: <482A3FA0050D21419C269D13989C6113085396A0@lavender-fe.eng.netapp.com>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cw6iu-0006PM-MW
	for nfs@lists.sourceforge.net; Tue, 01 Feb 2005 14:42:16 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cw6is-0003is-8W
	for nfs@lists.sourceforge.net; Tue, 01 Feb 2005 14:42:16 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C6113085396A0@lavender-fe.eng.netapp.com>
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

On Fri, 28 Jan 2005, Lever, Charles wrote:

> i believe there is also an option on statd to always use a particular
> nodename (-n ?).

as it turns out this was indeed the issue.

summary of our problem:

   - client obtains lock

   - server reboots

   - client cannot re-obtain lock (lockd recovery failure)


summary of setup:

   - all nfs clients and servers were multi-homed.  having front-door back-door
     interfaces like client.domain and client.b.domain, etc.

   - all nfs clients and servers were running iptables.  holes must be open for
     rpc.statd, etc.  in general we allowed all traffic between client and
     server on the backdoor.

summary of solution

   - rpc.statd reports to server during lock recovery.  it uses the output of
     gethostname (uname -n) by default.  in this case the client would attempt
     lock recovery using this hostname and the server would refuse since it
     expected to the see the name of the backdoor interface (client.b.domain)

     rpc.statd needs to be started using the '-n' (name) option to override the
     output of gethostname.  in our case (redhat) this is done by putting
     something like the following

       STATD_HOSTNAME=client.b.ngdc.noaa.gov

     into the file /etc/sysconfig/nfs, which is, itself, sourced by
     /etc/init.d/nfclock

lockd recovery now operates correctly.  thanks to all who helped!

kind regards.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
