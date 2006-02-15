From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: query about clnt_create
Date: Wed, 15 Feb 2006 11:08:57 -0500
Message-ID: <4d569c330602150808m2a2abe9dxc041eb16b5d926c3@mail.gmail.com>
References: <20060215145432.63194.qmail@web51604.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F9PDB-0003ZY-BN
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 08:09:01 -0800
Received: from nproxy.gmail.com ([64.233.182.203])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F9PDA-0007kn-NC
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 08:09:01 -0800
Received: by nproxy.gmail.com with SMTP id g2so344494nfe
        for <nfs@lists.sourceforge.net>; Wed, 15 Feb 2006 08:08:57 -0800 (PST)
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20060215145432.63194.qmail@web51604.mail.yahoo.com>
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

What kind of error do you get back from the clnt_create() ?

On 2/15/06, mehta kiran <kiranmehta1981@yahoo.com> wrote:
> Hi,
>     Can clnt_create for NFS versions fail in any
>     case due to security setting on NFS Sever ?
>     Description: NFS client can mount exported FS.
>     I have a small application which detects
>     health of NFS server by creating client
>     handle for required NFS version+protocol.
>     Can this ever fail consistenly
>     due to security or any other
>     settings on NFS server
>     (nfs client system and server are connected to
>     network, there is no hardware/(network load)
>     problem and portmapper + all nfs daemons are
>     runnnig)?
>
> thanks,
>  kiran
>
>
> __________________________________________________
> Do You Yahoo!?
> Tired of spam?  Yahoo! Mail has the best spam protection around
> http://mail.yahoo.com
>
>
> -------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc. Do you grep through log fi=
les
> for problems?  Stop!  Download the new AJAX search engine that makes
> searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
> http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D103432&bid=3D230486&dat=
=3D121642
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
