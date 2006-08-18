From: James Yarbrough <jmy@sgi.com>
Subject: Re: [PATCH 2/5] NLM failover - per fs grace period
Date: Fri, 18 Aug 2006 13:11:42 -0700
Message-ID: <44E61EFE.F41140AD@sgi.com>
References: <1155535221.3416.26.camel@localhost.localdomain>
	<1155894561.17651.442.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, lhh@redhat.com,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Wendy Cheng <wcheng@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GEAh1-0003qN-FI
	for nfs@lists.sourceforge.net; Fri, 18 Aug 2006 13:11:47 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GEAh0-0000Ex-Mj
	for nfs@lists.sourceforge.net; Fri, 18 Aug 2006 13:11:48 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
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

Greg Banks wrote:
> 
> On Mon, 2006-08-14 at 16:00, Wendy Cheng wrote:
> > This change enables per NFS-export entry lockd grace period.[...]
> 
> >
> > +/* Server fsid linked list for NLM lock failover */
> > +struct nlm_serv {
> > +     struct nlm_serv*        s_next;         /* linked list */
> > +     unsigned long           s_grace_period; /* per fsid grace period */
> > +     int                     s_fsid;         /* export fsid */
> > +};
> > +
> 
> The name of this structure appears to be left over from your
> previous approach; it doesn't really represent a server anymore.
> Giving the structure, and list, and the lock that protects it
> similar and appropriate names might be nice.
> 
> Also, the s_grace_period field isn't actually a period, it's
> the future expiry time expressed in jiffies.  The field name
> and comment are both confusing.

It might be a good idea to change s_grace_period to something like
s_grace_end since it actually marks the ending time of the grace period.
If you do change the name, it would be a good idea to enhance the
commentary to indicate the relationship of the field to the grace period.
That should leave enough breadcrumbs for anyone familiar with the NLM
terminology to follow.

-- 
jmy@sgi.com
650 933 3124

I need more snakes.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
