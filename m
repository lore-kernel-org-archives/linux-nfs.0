From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [KJ] Re: [NFS] [PATCH 7/40] fs/nfs4callback: replace
	schedule_timeout() with ssleep()
Date: Tue, 1 Mar 2005 16:31:39 -0500
Message-ID: <20050301213139.GA1985@fieldses.org>
References: <20050120190352.GH5393@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============14254075398780786=="
Cc: kernel-janitors@lists.osdl.org, nfs@lists.sourceforge.net,
   neilb@cse.unsw.edu.au
To: Nishanth Aravamudan <nacc@us.ibm.com>
In-Reply-To: <20050120190352.GH5393@us.ibm.com>
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-ID: <nfs.lists.sourceforge.net>

--===============14254075398780786==
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jan 20, 2005 at 11:03:52AM -0800, Nishanth Aravamudan wrote:
> Please consider applying.
> 
> Description: Use ssleep() instead of schedule_timeout() to guarantee the task
> delays as expected.

Thanks, but a different fix for this has been submitted.  (Our sleeping
at all there is a bug.)--b.

--===============14254075398780786==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============14254075398780786==--
