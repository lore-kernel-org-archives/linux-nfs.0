From: Al Active <LLLActive@GMX.Net>
Subject: Re: Searching NFS Archives
Date: Tue, 10 Jan 2006 17:23:10 +0100
Message-ID: <1136910191.6837.49.camel@L10-WS-AWS1.AWS>
References: <1136907278.6837.12.camel@L10-WS-AWS1.AWS>
	 <200601101645.14166.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EwMHJ-0005Pb-8k
	for nfs@lists.sourceforge.net; Tue, 10 Jan 2006 08:23:21 -0800
Received: from mail.gmx.net ([213.165.64.21])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EwMHG-0003nb-Lt
	for nfs@lists.sourceforge.net; Tue, 10 Jan 2006 08:23:21 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <200601101645.14166.vincent.roqueta@ext.bull.net>
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

Thanx for answering Vincent

On Tue, 2006-01-10 at 16:45 +0100, Vincent Roqueta wrote:
> Le Mardi 10 Janvier 2006 16:34, Al Active a =C3=A9crit :
> works for me:
> http://sourceforge.net/mailarchive/forum.php?forum=3Dnfs

I still can't open it ??

>=20
> I don't understand what you are trying to do?
> Samba clients can't access a NFS server...

No, I have one central SuSE Linux 10.0 server cluster for all data. It
exports NFS shares to a number of NFS-Servers. The NFS-Servers are also
clusters with heartbeat; one for Samba, another for Apache, another for
ERP. The Samba server, for eg. receives all data shares from the central
data cluster for a windows network over the NFS-Shares. =20

Data-Cluster           =20
NFS Shares Export
    |
    |
    v
|--1GB-IP--|
    |  |______________________
    |                        |
    v                        v
NFS-Shares Import      (Other Servers)
NFS-Server Cluster
(w/Samba)
SMB-Shares
    ^
    |
    v
|--100MB-IP--|
    ^
    |
    v
Windows Network

I can not write to Windows Office products over SMB shares in the
Windows Network on the Samba Server, and not with OpenOffice products on
directly on the NFS-Server shares. Text and script files can be edited.
OO can edit on the Data-Cluster mounted devices. The NFS-Export seems to
limit access to read only of eg. *.doc, *.rtf, *.xls files etc., also
then limiting access by Samba.

I am busy reading the NFS How-To to check the Server & Client setups. I
have an older system that does not have the problem. I will explain my
problem in more detail when I am through. Thanx.

>=20
> Vincent
>=20


:-)
Al



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log fi=
les
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=3D7637&alloc_id=3D16865&op=3Dclick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
