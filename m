From: "Chris Worley" <worleys@gmail.com>
Subject: File has different contents on different clients
Date: Sun, 20 Aug 2006 15:55:27 -0600
Message-ID: <f3177b9e0608201455w5930d488qe1200982a5602a39@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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

I'm using NFS on  a cluster, and one file seems to keep getting
different contents on different NFS clients, while having the proper
attributes on all clients:

           Here, the user queries all clients and greps for a value in the file:

bash-3.00$ pbs2pdsh 21647 grep n_pess /...PATH.../par | dshbak -c
----------------
c-21-[01,04,06-07,09-11,16,18-20,22-30],c-22-[01-30],c-23-[01-04,06-27,29-30],c-24-[01-04,06-30],c-26-[01-30],c-27-[01-30],c-28-[01-30],c-29-[01-30],c-30-[01-12,14-17,19]
----------------
 n_pess = 4
----------------
c-23-05,c-30-18
----------------
 n_pess = 8

            Most clients see the proper value of "4", two clients see
the old value of "8".
            But, all clients show the same modification time on the file:

[root@hn ~]# pdsh -a ls -l /...PATH/par | dshbak -c
----------------
c-21-[01-30],c-22-[01-30],c-23-[01-27,29-30],c-24-[01-04,06-30],c-26-[01-30],c-27-[01-30],c-28-[01-30],c-29-[01-30],c-30-[01-12,14-19]
----------------
 -rw-r--r--  1 anaraiki anaraiki 753 Aug 19 13:52 /...PATH.../par

            The checksum is also different on  many clients:

[root@hn ~]# pdsh -a sum /...PATH.../par | dshbak -c
----------------
c-21-[01,04,06-07,09-11,16-30],c-22-[01-30],c-23-[01-04,06-27,29-30],c-24-[01-04,06-30],c-26-[01-30],c-27-[01-30],c-28-[01-30],c-29-[01-30],c-30-[01-12,14-17,19]
----------------
 27851     1
----------------
c-21-[02-03,05,08,12-15],c-23-05,c-30-18
----------------
 44233     1

If I "touch" the file... all clients get back in sync.  This is the
second time it's happend to the same file, but different NFS clients
got out of sync.

We're running a 2.6.9-22 kernel w/ RHEL4U2.

Any ideas?

Thanks,

Chris

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
