From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] inotify: report rounded-up event size to user space
Date: Thu, 7 May 2009 19:59:47 +0800
Message-ID: <20090507115947.GA20934@localhost>
References: <20090503105456.GA30449@localhost> <20090503124013.GA31700@localhost> <ac3eb2510905030556p4ce25ff1w9aa5cbf76be2e206@mail.gmail.com> <20090504133019.GA14300@localhost> <ac3eb2510905060642o41f9c68rf1138e94d76d611c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	Eric Paris <eparis@redhat.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>,
	Kay Sievers <kay.sievers@vrfy.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <ac3eb2510905060642o41f9c68rf1138e94d76d611c@mail.gmail.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 06, 2009 at 09:42:58PM +0800, Kay Sievers wrote:
> On Mon, May 4, 2009 at 15:30, Wu Fengguang <fengguang.wu@intel.com> w=
rote:
>=20
> > I tried remove every udev rules in /etc/udev/ and /lib/udev, the /e=
tc/group
> > accesses disappeared in strace, but udevd is still busy.
>=20
> > ppoll([{fd=3D4, events=3DPOLLIN}, {fd=3D5, events=3DPOLLIN}, {fd=3D=
3, events=3DPOLLIN}], 3, NULL, [], 8) =3D 1 ([{fd=3D3, revents=3DPOLLIN=
}])
> > ioctl(3, FIONREAD, [39]) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0=3D 0
> > read(3, 0x62ad60, 39) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =3D -1 EINVAL (Invalid argument)
>=20
> Seems, you have issues with inotify on your nfs mount?
>=20
> Inotify wakes up udevd to tell something in the rules directory has
> changed, but inotify seems not to return anything useful, but keeps
> waking us up. That causes an endless loop of parsing rules files.

Thanks for the tip. The failed inotify read() is caused by the size *ro=
undup*
behavior introduced by the -mm commit 3b46cf7d5f3ca(Reimplement inotify=
_user
using fsnotify).  Which says:

+               /*
+                * We need to pad the filename so as to properly align =
an
+                * array of inotify_event structures.  Because the stru=
cture is
+                * small and the common case is a small filename, we ju=
st round
+                * up to the next multiple of the structure's sizeof.  =
This is
+                * simple and safe for all architectures.
+                */

The udev madness originates from these kernel testing failures:

[  756.569243] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  756.600103] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  756.630265] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  756.670862] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  756.701845] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  756.732899] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  756.763126] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  756.794829] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  756.824985] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  756.856760] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  761.608521] __ratelimit: 210 callbacks suppressed

Which are printed by the following patch:

--- a/fs/notify/inotify/inotify_user.c
+++ b/fs/notify/inotify/inotify_user.c
 static struct fsnotify_event *get_one_event(struct fsnotify_group *gro=
up,
 					    size_t count)
 {
 	size_t event_size =3D sizeof(struct inotify_event);
 	struct fsnotify_event *event;
=20
 	if (fsnotify_notify_queue_is_empty(group))
 		return NULL;
=20
 	event =3D fsnotify_peek_notify_event(group);
=20
 	event_size +=3D roundup(event->name_len, event_size);
=20
-	if (event_size > count)
+	if (event_size > count) {
+		if (printk_ratelimit())
+			printk("get_one_event: event_size=3D%d > count=3D%d, name_len=3D%d,=
 name=3D%s\n",
+					(int)event_size, (int)count, (int)event->name_len, event->file_na=
me);
 		return ERR_PTR(-EINVAL);
+	}


It can be fixed by reporting the rounded up value to user space.

Thanks,
=46engguang
---
inotify: report rounded-up event size to user space

=46ix a udev madness problem, which falls into an endless loop:

(1) ppoll([{fd=3D4, events=3DPOLLIN}, {fd=3D5, events=3DPOLLIN}, {fd=3D=
3, events=3DPOLLIN}], 3, NULL, [], 8) =3D 1 ([{fd=3D3, revents=3DPOLLIN=
}])
(2) ioctl(3, FIONREAD, [39]) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0=3D 0
(3) read(3, 0x62ad60, 39) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =3D -1 EINVAL (Invalid argument)

In (2) we reported a small len, while in (3) we insist on a rounded up =
len,
leading to a failed inotify read(), which will be retried endlessly by =
udev.

[  756.569243] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  756.600103] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  756.630265] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  756.670862] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  756.701845] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  756.732899] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  756.763126] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  756.794829] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  756.824985] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  756.856760] get_one_event: event_size=3D48 > count=3D38, name_len=3D=
22, name=3D61-dev-root-link.rules
[  761.608521] __ratelimit: 210 callbacks suppressed

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/notify/inotify/inotify_user.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- linux.orig/fs/notify/inotify/inotify_user.c
+++ linux/fs/notify/inotify/inotify_user.c
@@ -318,7 +318,9 @@ static long inotify_ioctl(struct file *f
 		mutex_lock(&group->notification_mutex);
 		list_for_each_entry(holder, &group->notification_list, event_list) {
 			event =3D holder->event;
-			send_len +=3D sizeof(struct inotify_event) + event->name_len;
+			send_len +=3D sizeof(struct inotify_event);
+			send_len +=3D roundup(event->name_len,
+					sizeof(struct inotify_event));
 		}
 		mutex_unlock(&group->notification_mutex);
 		ret =3D put_user(send_len, (int __user *) p);
--
To unsubscribe from this list: send the line "unsubscribe linux-hotplug=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
