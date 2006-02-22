From: CHIKAMA masaki <masaki-c@nict.go.jp>
Subject: Re: Writing to an NFS share truncates files on >8Tb Raid +
 LVM2
Date: Wed, 22 Feb 2006 19:45:41 +0900
Message-ID: <20060222194541.4167cd7a.masaki-c@nict.go.jp>
References: <43FC3ED3.2060908@vanalteren.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FBrVE-0005eu-9o
	for nfs@lists.sourceforge.net; Wed, 22 Feb 2006 02:45:48 -0800
Received: from ns1.nict.go.jp ([133.243.3.1])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FBrVA-0005rk-SW
	for nfs@lists.sourceforge.net; Wed, 22 Feb 2006 02:45:48 -0800
Received: from gw1.nict.go.jp (gw1.nict.go.jp [133.243.18.250])
	by ns1.nict.go.jp  with ESMTP id k1MAjgEj015962
	for <nfs@lists.sourceforge.net>; Wed, 22 Feb 2006 19:45:42 +0900 (JST)
Received: from gw1.nict.go.jp (localhost [127.0.0.1])
	by gw1.nict.go.jp  with ESMTP id k1MAjfN5028405
	for <nfs@lists.sourceforge.net>; Wed, 22 Feb 2006 19:45:41 +0900 (JST)
Received: from mail1.nict.go.jp (mail.nict.go.jp [133.243.18.3])
	by gw1.nict.go.jp  with ESMTP id k1MAjfks028402
	for <nfs@lists.sourceforge.net>; Wed, 22 Feb 2006 19:45:41 +0900 (JST)
Received: from mail1.nict.go.jp (localhost [127.0.0.1])
	by localhost.nict.go.jp (Postfix) with ESMTP id 8354C43E3
	for <nfs@lists.sourceforge.net>; Wed, 22 Feb 2006 19:45:41 +0900 (JST)
Received: from nabal.nict.go.jp (unknown [133.243.93.85])
	by mail1.nict.go.jp (Postfix) with SMTP id 4902B42CB
	for <nfs@lists.sourceforge.net>; Wed, 22 Feb 2006 19:45:41 +0900 (JST)
To: nfs@lists.sourceforge.net
In-Reply-To: <43FC3ED3.2060908@vanalteren.nl>
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

Hello Ramon.

On Wed, 22 Feb 2006 11:37:07 +0100
Ramon van Alteren <ramon@vanalteren.nl> wrote:

> We're using reiserfsv3. It's a raid-50 machine based on two raid-50
> arrays of 4,55 Tb handled  by the hardware controller.

I had a similar problem before, and I'm sure it's because using reiserfsv3.
The reiserfsv3 does not support > 8TB filesystem.

Please see my post the following.

http://sourceforge.net/mailarchive/forum.php?forum_id=4930&max_rows=25&style=flat&viewmonth=200511&viewday=1


-- 
CHIKAMA Masaki @ NICT



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
