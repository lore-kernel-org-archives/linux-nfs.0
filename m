From: Denis Vlasenko <vda@ilport.com.ua>
Subject: mountd: needless DNS queries when authenticating client against numeric IP
Date: Fri, 4 Mar 2005 14:24:22 +0200
Message-ID: <200503041424.22897.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D7BsB-0002u3-Du
	for nfs@lists.sourceforge.net; Fri, 04 Mar 2005 04:25:39 -0800
Received: from [195.66.192.168] (helo=port.imtp.ilyichevsk.odessa.ua)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1D7Bs0-0000N9-IJ
	for nfs@lists.sourceforge.net; Fri, 04 Mar 2005 04:25:39 -0800
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

mount 127.0.0.1:/ can fail if DNS is down
and mountd has been restarted without re-run of exportfs -r,
because /var/lib/nfs/etab contains wrong hostname ("localhost"
instead of "127.0.0.1") and mountd cannot determine that
these are the same. This was explained in my previous mail.

Here is another, lesser problem:

If mountd was restarted _with_ prior run of exportfs -r, etab is correct
and mount succeeds, but with ~10 sec delay because of:

nfs_export *
auth_authenticate(char *what, struct sockaddr_in *caller, char *path)
{
        nfs_export      *exp = NULL;
        char            epath[MAXPATHLEN+1];
        char            *p = NULL;
        struct hostent  *hp = NULL;
        struct in_addr  addr = caller->sin_addr;
        enum auth_error error;

        if (path [0] != '/') {
                xlog(L_WARNING, "bad path in %s request from %s: \"%s\"",
                     what, inet_ntoa(addr), path);
                return exp;
        }

        strncpy(epath, path, sizeof (epath) - 1);
        epath[sizeof (epath) - 1] = '\0';
        auth_fixpath(epath); /* strip duplicate '/' etc */

xlog(L_ERROR, "auth_authenticate(): get_reliable_hostbyaddr start"); //vda:
===>    hp = get_reliable_hostbyaddr((const char*)&caller->sin_addr, sizeof(struct in_addr),
                                     AF_INET);
        ^^^^^^^^^^^^^^^^^ gethostbyaddr inside. we will wait for DNS reply (or timeout)
        if (!hp)
                hp = get_hostent((const char*)&caller->sin_addr, sizeof(struct in_addr),
                                     AF_INET);
        if (!hp)
                return exp;

This DNS query is not needed in my case.

Shall we first try to authenticate against numeric IP of client
and retry with hostname returned from get_reliable_hostbyaddr()
only if we fail auth against numeric IP?
--
vda



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
